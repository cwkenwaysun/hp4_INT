/*
David Hancock
FLUX Research Group
University of Utah
dhancock@cs.utah.edu

HyPer4: A P4 Program to Run Other P4 Programs

hp4.p4: Define the ingress and egress pipelines, including multicast support.
*/

#include "includes/defines.p4"
#include "includes/headers.p4"
#include "includes/parser.p4"
#include "includes/deparse_prep.p4"
#include "includes/setup.p4"
#include "includes/stages.p4"
#include "includes/checksums.p4"
#include "includes/resize_pr.p4"
//#include "includes/debug.p4"

metadata meta_ctrl_t meta_ctrl;
metadata meta_primitive_state_t meta_primitive_state;
metadata extracted_t extracted;
metadata tmeta_t tmeta;
metadata csum_t csum;

metadata intrinsic_metadata_t intrinsic_metadata;

action modify_t1() {
    modify_field(int_head.timestamp1, intrinsic_metadata.ingress_global_timestamp);
    add_to_field(int_head.position, 1);
}

action modify_t2() {
    modify_field(int_head.timestamp2, intrinsic_metadata.ingress_global_timestamp);
    add_to_field(int_head.position, 1);
}

action modify_t3() {
    modify_field(int_head.timestamp3, intrinsic_metadata.ingress_global_timestamp);
    add_to_field(int_head.position, 1);
}

action do_phys_fwd_only(spec, filter) {
  modify_field(standard_metadata.egress_spec, spec);
  modify_field(meta_ctrl.efilter, filter);
}

action do_bmv2_mcast(mcast_grp, filter) {
  modify_field(intrinsic_metadata.mcast_grp, mcast_grp);
  modify_field(meta_ctrl.efilter, filter);
}

action do_virt_fwd() {
  modify_field(standard_metadata.egress_spec, standard_metadata.ingress_port);
  modify_field(meta_ctrl.virt_fwd_flag, 1);
}

table t1 {
    reads {
        int_head.position: exact;
    }
    actions {
        modify_t1;
        modify_t2;
        modify_t3;
    }
    size: 5;
}

table t_virtnet {
  reads {
    meta_ctrl.vdev_ID : exact;
    meta_ctrl.virt_egress_spec : exact;
  }
  actions {
    a_drop;
    do_phys_fwd_only;
    do_bmv2_mcast;
    do_virt_fwd;
  }
}

control ingress {
  apply(t1);

  setup();

  if (meta_ctrl.stage == NORM) { // 15
    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 1) { // 16|117|218|...
      stage1(); // stages.p4
    }

    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 2) { // 16|117|218|...
      stage2(); // stages.p4
    }

    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 3) { // 16|117|218|...
      stage3(); // stages.p4
    }

    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 4) { // 16|117|218|...
      stage4(); // stages.p4
    }

    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 5) { // 16|117|218|...
      stage5(); // stages.p4
    }

    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 6) { // 16|117|218|...
      stage6(); // stages.p4
    }

    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 7) { // 16|117|218|...
      stage7(); // stages.p4
    }
    if (meta_ctrl.dropped == 0) {
      apply(t_virtnet);
    }
  }
}

//table thp4_egress_filter_case1 {
//  reads {
//    meta_ctrl.vdev_ID : exact;
//  }
//  actions {
//    _no_op;
//    a_drop;
//  }
//}

//table thp4_egress_filter_case2 {
//  reads {
//    meta_ctrl.vdev_ID : exact;
//  }
//  actions {
//    _no_op;
//    a_drop;
//  }
//}

//field_list fl_virtnet {
//  meta_ctrl.vdev_ID;
//  meta_ctrl.virt_egress_port;
//  standard_metadata;
//}

//action a_virtnet_forward(next_vdev) {
//  modify_field(meta_ctrl.vdev_ID, next_vdev);
//  recirculate(fl_virtnet);
//}

//table thp4_out_virtnet {
//  reads {
//    meta_ctrl.vdev_ID : exact;
//    meta_ctrl.virt_egress_port : exact;
//  }
//  actions {
//    _no_op;
//    a_virtnet_forward;
//  }
//}

field_list fl_recirc {
  standard_metadata;
  meta_ctrl.vdev_ID;
  meta_ctrl.next_vdev_ID;
  meta_ctrl.virt_ingress_port;
  meta_ctrl.stage;
  meta_ctrl.virt_egress_spec;
  meta_ctrl.orig_virt_ingress_port;
}

field_list fl_clone {
  standard_metadata;
  meta_ctrl.vdev_ID;
  meta_ctrl.next_vdev_ID;
  meta_ctrl.virt_ingress_port;
  meta_ctrl.virt_egress_spec;
  meta_ctrl.virt_fwd_flag;
}

action vfwd(vdev_ID, vingress) {
  modify_field(meta_ctrl.next_vdev_ID, vdev_ID);
  modify_field(meta_ctrl.virt_ingress_port, vingress);
  modify_field(meta_ctrl.stage, VFWD);
  recirculate(fl_recirc);
}

action vmcast(vdev_ID, vingress) {
  modify_field(meta_ctrl.next_vdev_ID, vdev_ID);
  modify_field(meta_ctrl.virt_ingress_port, vingress);
  modify_field(meta_ctrl.virt_egress_spec, meta_ctrl.virt_egress_spec + 1);
  modify_field(meta_ctrl.stage, VFWD);
  recirculate(fl_recirc);
  clone_egress_pkt_to_egress(standard_metadata.egress_port, fl_clone);
}

action vmcast_phys(vdev_ID, vingress, phys_spec) {
  modify_field(meta_ctrl.next_vdev_ID, vdev_ID);
  modify_field(meta_ctrl.virt_ingress_port, vingress);
  modify_field(meta_ctrl.virt_egress_spec, meta_ctrl.virt_egress_spec + 1);
  modify_field(meta_ctrl.stage, VFWD);
  recirculate(fl_recirc);
  clone_egress_pkt_to_egress(phys_spec, fl_clone);
}

action pmcast(phys_spec) {
  modify_field(meta_ctrl.virt_egress_spec, meta_ctrl.virt_egress_spec + 1);
  clone_egress_pkt_to_egress(phys_spec, fl_clone);
}

table t_egr_virtnet {
  reads {
    meta_ctrl.vdev_ID : exact;
    meta_ctrl.virt_egress_spec : exact;
  }
  actions {
    vfwd;
    vmcast;
    vmcast_phys;
    pmcast;
    a_drop;
  }
}

table egress_filter { actions { a_drop; } }

control egress {
  // egress filtering, recirculation
  //if(standard_metadata.egress_port == standard_metadata.ingress_port) {
  //  if(meta_ctrl.virt_egress_port == 0) {
  //    apply(thp4_egress_filter_case1);
  //  }
  //  else {
  //    apply(thp4_out_virtnet);
  //  }
  //}
  //if(meta_ctrl.virt_egress_port == meta_ctrl.virt_ingress_port) {
  //  if(standard_metadata.egress_spec == standard_metadata.ingress_port) {
  //    apply(thp4_egress_filter_case2);
  //  }
  //}
  if(meta_ctrl.virt_fwd_flag == 1) { // 724
    apply(t_egr_virtnet); // recirculate, maybe clone_e2e
  }

  else if((standard_metadata.egress_port == standard_metadata.ingress_port) and
          (meta_ctrl.efilter == 1)) { // 725
    apply(egress_filter);
  }

  apply(t_checksum);          // checksums.p4
  apply(t_resize_pr);         // resize_pr.p4
  apply(t_prep_deparse_SEB);  // deparse_prep.p4
  if(parse_ctrl.numbytes > 40) { // 726
    apply(t_prep_deparse_40_59);
    if(parse_ctrl.numbytes > 60) {
      apply(t_prep_deparse_60_79);
      if(parse_ctrl.numbytes > 80) {
        apply(t_prep_deparse_80_99);
      }
    }
  }
}
