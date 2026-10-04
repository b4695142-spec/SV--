// 知识点：SystemVerilog 断言(Assertion)
// 1. 立即断言(Immediate Assertion)：在过程块中执行，基于当前时刻变量值判断
//    语法：assert (condition);
// 2. 并发断言(Concurrent Assertion)：基于时钟周期连续评估，可描述时序关系
//    语法：assert property (property_expr);
// 3. sequence：定义时序序列，可被property引用，实现复用
// 4. 带参数的sequence：通过参数化提高灵活性
// 5. property：封装并发断言逻辑，可引用sequence

// ============================================================
// 版本1：原始立即断言(Immediate Assertion)
// ============================================================
module asertion_ex;
    bit clk, a, b;
    always #5 clk = ~clk;  // 时钟生成，周期10ns

    initial begin
        a = 1; b = 1;   // t=0: a=1, b=1
        #15 b = 0;       // t=15: b=0
        #10 b = 1;       // t=25: b=1
        a = 0;           // t=25: a=0
        #20 a = 1;       // t=45: a=1
        #20;             // t=65
        $finish;         // 结束仿真
    end

    // 立即断言：在always块中，每个posedge clk时检查a&&b
    always @(posedge clk) check_a_and_b: assert (a && b);
endmodule

// 运行结果（立即断言）：
// t=5:  a=1,b=1 → PASS
// t=15: a=1,b=0 → FAIL (与b=0赋值存在竞争)
// t=25: a=0,b=1 → FAIL
// t=35: a=0,b=1 → FAIL
// t=45: a=1,b=1 → PASS
// t=55: a=1,b=1 → PASS
// t=65: 仿真结束


// ============================================================
// 版本2：改写为并发断言(Concurrent Assertion)
// ============================================================
module concurrent_assertion_ex;
    bit clk, a, b;
    always #5 clk = ~clk;

    initial begin
        a = 1; b = 1;
        #15 b = 0;
        #10 b = 1;
        a = 0;
        #20 a = 1;
        #20;
        $finish;
    end

    // 并发断言：使用assert property，基于时钟周期连续评估
    property p_a_and_b;
        @(posedge clk) a && b;  // 每个时钟上升沿检查a&&b
    endproperty
    check_a_and_b: assert property (p_a_and_b);
endmodule

// 运行结果（并发断言）：
// 与立即断言结果一致，但并发断言在时钟沿采样，更稳定
// t=5:  PASS | t=15: FAIL | t=25: FAIL | t=35: FAIL | t=45: PASS | t=55: PASS


// ============================================================
// 版本3：利用sequence改写断言
// ============================================================
module sequence_assertion_ex;
    bit clk, a, b;
    always #5 clk = ~clk;

    initial begin
        a = 1; b = 1;
        #15 b = 0;
        #10 b = 1;
        a = 0;
        #20 a = 1;
        #20;
        $finish;
    end

    // sequence定义时序序列，可被property引用
    sequence s_a_and_b;
        a && b;  // 当前时刻a和b都为真
    endsequence

    property p_a_and_b;
        @(posedge clk) s_a_and_b;  // 每个时钟上升沿检查sequence
    endproperty
    check_a_and_b: assert property (p_a_and_b);
endmodule

// 运行结果：与版本2一致
// sequence优势：将时序逻辑封装，便于复用


// ============================================================
// 版本4：利用带参数的sequence改写断言
// ============================================================
module param_sequence_assertion_ex;
    bit clk, a, b;
    always #5 clk = ~clk;

    initial begin
        a = 1; b = 1;
        #15 b = 0;
        #10 b = 1;
        a = 0;
        #20 a = 1;
        #20;
        $finish;
    end

    // 带参数的sequence：通过参数传入信号，提高灵活性
    sequence s_sig_and_sig(bit x, bit y);
        x && y;  // 检查x和y是否都为真
    endsequence

    property p_a_and_b;
        @(posedge clk) s_sig_and_sig(a, b);  // 传入a和b
    endproperty
    check_a_and_b: assert property (p_a_and_b);

    // 优势：同一sequence可用于不同信号组合，例如：
    // property p_a_and_clk;
    //     @(posedge clk) s_sig_and_sig(a, clk);
    // endproperty
endmodule

// 运行结果：与版本2、3一致
// 带参数sequence优势：参数化设计，同一sequence可复用于不同信号组合
