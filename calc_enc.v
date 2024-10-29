module decoder (output wire [3:0] B,
input wire R,L,C);
wire An,Bn,Cn,Dn,En,Fn,Gn,Hn,In,Jn,n0,n1,n2,n3,n4,n5;

//Figure 2: 1st bit (alu_op[0])
  not U0 (An,R);
  xor U1(Bn,L,C);
  and U2(n0,An,L);
  and U3(n1,R,Bn);
  or U4(B[0],n0,n1);

//Figure 3: 2nd bit (alu_op[1])
  and U5 (Cn,R,L);
  not U6(Dn,L);
  not U7(En,C);
  and U8(n2,Dn,En);
  or U9(B[1],n2,Cn);

//Figure 4: 3rd bit (alu_op[2])
  and U10(Fn,R,L);
  xor U11(Gn,R,L);
  not U12(Hn,C);
  or U13(n3,Fn,Gn);
  and U14(B[2],n3,Hn);

//Figure 5: 4th bit (alu_op[3])
  not U15(In,R);
  xnor U16(Jn,R,C);
  and U17(n4,In,C);
  or U18(n5,n4,Jn);
  and U19(B[3],n5,L);

endmodule 
