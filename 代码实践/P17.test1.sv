// 知识点：SystemVerilog 功能覆盖率(Coverage)
// 1. covergroup：覆盖率组，定义需要收集覆盖率的变量和采样点
// 2. coverpoint：覆盖点，指定要收集覆盖率的变量，自动统计所有可能值
// 3. ck.sample()：手动触发覆盖率采样
// 4. bit[2:0] port：3位端口，共8个值(0~7)，覆盖率为采样到的值/8
// 5. modport：接口中定义信号方向，约束使用者的访问权限
// 6. program块：用于测试平台，automatic修饰符使变量自动分配

// 接口定义：封装DUT与testbench之间的信号
interface busifc(input logic clk);
    logic [7:0] data;
    logic [2:0] port;
    modport TB(input data, input port, input clk);  // TB modport：只读
endinterface

class Transaction;
    rand bit [31:0] data;
    rand bit [2:0]  port;  // 八个端口号(0~7)
endclass

program automatic test(busifc.TB ifc);
    covergroup CovPort;
        coverpoint ifc.port;  // 衡量port的覆盖率，统计0~7各值出现次数
    endgroup
    
    initial begin
        Transaction tr;
        CovPort ck;
        ck = new();  // 实例化覆盖率分组
        tr = new();
        repeat(32) begin  // 运行32次循环
            assert(tr.randomize());  // 随机化transaction
            ifc.port <= tr.port;    // 传输port到interface
            ifc.data <= tr.data;   // 传输data到interface
            ck.sample();           // 收集覆盖率数据
            @(ifc.clk);            // 等待一个时钟周期
        end
        // 打印覆盖率报告
        $display("Coverage = %0.2f%%", ck.get_coverage());
    end
endprogram

module tb_top;
    logic clk = 0;
    busifc ifc(clk);  // 实例化接口

    // 时钟生成
    initial begin
        forever #5 clk = ~clk;  // 周期10ns的时钟
    end

    // 仿真控制
    initial begin
        repeat(400) @(posedge clk);
        $finish;
    end

    // 实例化program块
    test t(ifc);
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// Coverage = 100.00%
//
// 解析：
// 32次随机采样，port为3位共8个值(0~7)
// 每个值平均出现4次(32/8)，大概率覆盖全部8个值
// get_coverage()返回所有coverpoint的覆盖率，100%表示8个端口值均已覆盖
