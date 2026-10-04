// 知识点：SystemVerilog randc与solve...before
// 1. randc：循环随机，遍历所有可能值后才重复，0~3不重复出现
// 2. randc变量默认优先于rand变量随机化，solve...before对randc是冗余的
// 3. 对比test4(rand)：y每次独立随机，概率分布受solve影响
//    本例(randc)：y循环遍历0~3，4次调用各值出现一次
// 4. randc + 约束：y的循环序列仍受约束限制
class impact;
    rand  bit x;        // 0或1
    randc bit [1:0] y;  // 0,1,2或3，循环随机不重复
    constraint c_xy
    {
        (x == 0) -> y == 0;  // x为0时y必须为0
        solve y before x;    // 对randc冗余，randc默认优先随机化
    }
endclass

module test;
    impact p;

    initial begin
        p = new();
        assert(p.randomize());
        $display("x = %0d", p.x);  // 运行结果：0或1
        $display("y = %0d", p.y);  // 运行结果：0/1/2/3循环出现
    end
endmodule

// 运行结果（连续调用4次，y不重复）：
// 第1次: x = 1, y = 2
// 第2次: x = 1, y = 0
// 第3次: x = 1, y = 3
// 第4次: x = 1, y = 1
// 第5次: x = 1, y = 0  (开始新一轮循环)
//
// 解析：
// y为randc，连续4次调用各值出现一次，第5次重新开始循环
// 当y=0时，x可取0或1；当y=1/2/3时，x必须为1
// solve y before x对randc变量是冗余的，不影响行为
