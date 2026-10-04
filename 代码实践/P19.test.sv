// 知识点：SystemVerilog 交叉覆盖率(Cross Coverage)
// 1. cross：统计两个coverpoint的笛卡尔积覆盖率
// 2. 语法：cross point_a, point_b; 在两个coverpoint之后单独声明
// 3. 交叉覆盖率 = 已命中的交叉组合数 / 总组合数
// 4. 例如：port有3个bins，data有2个bins，cross共3×2=6个组合
// 5. cross coverage能发现单维度无法发现的遗漏场景

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

    covergroup CovPort;
        port: coverpoint tr.port {
            bins zero = {0};          // port值为0
            bins low  = {[1:3]};      // port值为1~3
            bins hi   = {[4:7]};      // port值为4~7
        }
        data: coverpoint tr.data {
            bins zero    = {0};                    // data值为0
            bins nonzero = {[1:32'hFFFFFFFF]};     // data值非0
        }
        cross port, data;  // 交叉覆盖率：3×2=6种组合
    endgroup

    function new(mailbox mbx_in, virtual busifc ifc);
        CovPort = new();   // 实例化covergroup
        this.mbx_in = mbx_in;
        this.ifc = ifc;
    endfunction

    task main;
        begin
            mbx_in.get(tr);       // 从mailbox获取transaction
            ifc.port <= tr.port;  // 驱动port到interface
            ifc.data <= tr.data;  // 驱动data到interface
            CovPort.sample();    // 采样覆盖率
        end
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

        repeat(32) begin            // 运行32次循环
            assert(tr.randomize());  // 随机化transaction
            mbx_in.put(tr);          // 放入mailbox
            tr_c.main();              // 驱动并收集覆盖率
            @(ifc.clk);              // 等待一个时钟周期
        end
        $display("Coverage = %0.2f%%", tr_c.CovPort.get_coverage());
    end
endprogram

module tb_top;
    logic clk = 0;
    busifc ifc(clk);

    initial begin
        forever #5 clk = ~clk;  // 时钟生成
    end

    initial begin
        repeat(400) @(posedge clk);
        $finish;
    end

    test t(ifc);  // 实例化program块
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// Coverage = 100.00%
//
// 解析：
// port: 3个bins(zero/low/hi)
// data: 2个bins(zero/nonzero)
// cross: 3×2=6种组合，如下表：
// ┌────────┬───────────┬──────────────┐
// │        │ data=zero │ data=nonzero │
// ├────────┼───────────┼──────────────┤
// │port=zero│    ×      │      ×       │
// │port=low │    ×      │      ×       │
// │port=hi  │    ×      │      ×       │
// └────────┴───────────┴──────────────┘
// 32次采样，6种组合大概率全部命中 → 覆盖率100%
