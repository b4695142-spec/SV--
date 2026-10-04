// 知识点：SystemVerilog 基于Transactor的覆盖率收集
// 1. mailbox：进程间通信机制，put()发送，get()接收
// 2. Transactor类：封装驱动和覆盖率收集，职责分离
// 3. 内嵌covergroup：covergroup定义在类内部，可直接访问类成员
// 4. CovPort = new()：在构造函数中实例化内嵌covergroup
// 5. virtual interface：类中通过虚拟接口驱动DUT信号

// 接口定义
interface busifc(input logic clk);
    logic [31:0] data;
    logic [2:0]  port;
endinterface

class Transaction;
    rand logic [31:0] data;
    rand logic [2:0]  port;  // 八个端口号(0~7)
endclass

class Transactor;
    Transaction tr;
    mailbox mbx_in;
    virtual busifc ifc;
    
    covergroup CovPort;        // 内嵌covergroup，可直接访问tr.port
        coverpoint tr.port;
    endgroup
   
    function new(mailbox mbx_in, virtual busifc ifc);
        CovPort = new();       // 实例化内嵌covergroup
        this.mbx_in = mbx_in;
        this.ifc = ifc;
    endfunction
    
    task main;
        mbx_in.get(tr);        // 从mailbox获取transaction
        ifc.port <= tr.port;   // 驱动port到interface
        ifc.data <= tr.data;   // 驱动data到interface
        CovPort.sample();      // 收集覆盖率数据
    endtask
endclass

program automatic test(busifc ifc);
    initial begin
        Transaction tr;
        mailbox mbx_in;
        Transactor tr_c;
        tr = new();
        mbx_in = new();
        tr_c = new(mbx_in, ifc);  // 创建Transactor，传入mailbox和interface
        
        repeat(32) begin          // 运行32次循环
            assert(tr.randomize()); // 随机化transaction
            mbx_in.put(tr);         // 将transaction放入mailbox
            tr_c.main();            // Transactor取数据、驱动并收集覆盖率
            @(ifc.clk);             // 等待一个时钟周期
        end
        $display("Coverage = %0.2f%%", tr_c.CovPort.get_coverage());
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
// 与P17.test1相比，本例将驱动和覆盖率收集封装到Transactor类中
// 程序通过mailbox将transaction传递给Transactor，实现了解耦
// 32次随机采样，port共8个值(0~7)，大概率覆盖全部
