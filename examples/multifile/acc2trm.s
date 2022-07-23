.MODULE Acc2Trm
;       copy accumulator to term register
acc2trm
        sts     svstack
        lds     trm_lsb
        ldx     acc_lsb
_again  ldaa    ,x      ;5
        psha            ;2
        dex             ;3
        cpx     acc_msb ;6
        bhs     _again  ;3
        lds     svstack
        rts
