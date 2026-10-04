// 知识点：SystemVerilog 指定变量随机化(randomize(var))
// 1. randomize()：随机化所有rand变量
// 2. randomize(var)：仅随机化指定变量，其他rand变量保持不变
// 3. 只有声明为rand/randc的变量才能作为randomize()的参数
// 4. 指定变量随机化时，约束仍需满足，非指定变量保持原值
class Rising;
    rand byte low;        // 改为rand，否则不能作为randomize()参数
    rand byte med, hi;
    constraint c_up {low < med; med < hi;}  // 递增约束
endclass

module test;
    Rising r;

    initial begin
        r = new();
        r.randomize();  // 随机化所有rand变量(low, med, hi)
        $display("r::low is %0d, r::med is %0d, r::hi is %0d", r.low, r.med, r.hi);
        // 运行结果：low,med,hi均为随机值，且满足low<med<hi

        r.randomize(med);  // 仅随机化med，low和hi保持不变
        $display("r::low is %0d, r::med is %0d, r::hi is %0d", r.low, r.med, r.hi);
        // 运行结果：low和hi不变，仅med被随机化（仍需满足约束low<med<hi）

        r.randomize(low);  // 仅随机化low，med和hi保持不变
        $display("r::low is %0d, r::med is %0d, r::hi is %0d", r.low, r.med, r.hi);
        // 运行结果：med和hi不变，仅low被随机化（仍需满足约束low<med）
    end
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// r::low is -50, r::med is 20, r::hi is 100
// r::low is -50, r::med is 30, r::hi is 100
// r::low is -80, r::med is 30, r::hi is 100
//
// 解析：
// 第一次 randomize()：随机化low,med,hi，三者满足low<med<hi
// 第二次 randomize(med)：仅med被随机化，low和hi保持上次值不变
// 第三次 randomize(low)：仅low被随机化，med和hi保持上次值不变

// 思考：为什么打印的hi数值一致？
// 答：因为第二次和第三次随机分别只指定了med和low作为randomize()参数，
//     hi未被指定随机化，因此保持第一次randomize()时的值不变。
//     randomize(var)只会随机化指定变量，其他rand变量保持原值。
