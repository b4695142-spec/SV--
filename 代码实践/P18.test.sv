// 知识点：SystemVerilog 覆盖点bins(覆盖仓)
// 1. bins：将coverpoint的取值范围划分为多个"仓"，分别统计覆盖率
// 2. 单值bins：bins zero = {0}; 只统计值为0的采样
// 3. 区间bins：bins low = {[1:3]}; 统计1~3的采样
// 4. 自动bins：未定义bins时，求解器自动为每个值创建一个bin
// 5. 覆盖率 = 已采样到的bins数 / 总bins数
// 6. 定义bins后，只有命中的bins才计入覆盖率，更精确控制统计

// 接口定义
interface busifc(input logic clk);
    logic [31:0] data;
    logic [2:0]  port;
endinterface

class Transaction;
    rand logic [31:0] data;
    rand logic [2:0]  port;
endclass

class Transactor;
    Transaction tr;
    mailbox mbx_in;
    virtual busifc ifc;
    
    covergroup covport;
        coverpoint tr.port
        {
            bins zero = {0};          // port值为0的仓
            bins low  = {[1:3]};      // port值为1~3的仓
            bins hi   = {[4:7]};      // port值为4~7的仓
        }
    endgroup
    
    function new(mailbox mbx_in, virtual busifc ifc);
        covport = new();   // 实例化covergroup
        this.mbx_in = mbx_in;
        this.ifc = ifc;
    endfunction
    
    task main;
        mbx_in.get(tr);       // 从mailbox获取transaction
        ifc.port <= tr.port;  // 驱动port到interface
        ifc.data <= tr.data;  // 驱动data到interface
        covport.sample();     // 采样覆盖率
    endtask
endclass

program automatic test(busifc ifc);
    initial begin
        Transaction tr;
        mailbox mbx_in;
        Transactor tr_c;
        tr = new();
        mbx_in = new();
        tr_c = new(mbx_in, ifc);
        
        repeat(32) begin           // 运行32次循环
            assert(tr.randomize()); // 随机化transaction
            mbx_in.put(tr);         // 放入mailbox
            tr_c.main();            // 驱动并收集覆盖率
            @(ifc.clk);             // 等待一个时钟周期
        end
        $display("Coverage = %0.2f%%", tr_c.covport.get_coverage());
    end
endprogram

module tb_top;
    logic clk = 0;
    busifc ifc(clk);

    initial begin
        forever #5 clk = ~clk;
    end

    initial begin
        repeat(400) @(posedge clk);
        $finish;
    end

    test t(ifc);
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// Coverage = 100.00%
//
// 解析：
// port为3位(0~7)，划分为3个bins：
//   zero: {0}       → 命中时记1
//   low:  {[1:3]}   → 1/2/3任一命中即记1
//   hi:   {[4:7]}   → 4/5/6/7任一命中即记1
// 32次随机采样，3个bins大概率全部命中 → 覆盖率100%
//
// 对比P17(无bins，8个自动bin，需8个值都出现)：
// 本例只有3个bins，更容易达到100%覆盖率
