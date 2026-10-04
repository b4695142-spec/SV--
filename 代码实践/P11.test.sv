// 知识点：SystemVerilog 基于类的验证平台(Testbench)架构
// 1. interface：封装DUT与testbench之间的连接信号，virtual interface用于类中访问
// 2. transaction：定义激励数据的随机化类，用rand声明可随机化变量
// 3. driver：通过virtual interface驱动激励到DUT，是验证平台的核心组件
// 4. always_ff：时序逻辑块，敏感列表包含时钟上升沿和复位下降沿
// 5. 非阻塞赋值(<=)：时序逻辑中使用，避免竞争
// 6. assert(tr.randomize())：断言随机化成功，失败会报错
// 7. @(posedge vif.clk)：等待时钟上升沿，实现与DUT同步驱动
// ============================================================

// 1.interface：封装DUT与testbench之间的连接信号
interface counter_if (input logic clk);
    logic       load_valid;
    logic [3:0] load_value;
endinterface

// 2.transaction：定义激励数据的随机化类
class transaction;
    rand logic       load_valid;
    rand logic [3:0] load_value;
endclass

// 3.DUT：计数器模块
module counter(
               input  logic       resetn,
               input  logic       clk,
               input  logic [3:0] load_value,
               input  logic       load_valid,
               output logic [3:0] q
               );
    
    always_ff @(posedge clk or negedge resetn) begin
        if(!resetn)
            q <= 4'd0;
        else if (load_valid)
            q <= load_value;
        else 
            q <= q + 1;
    end
endmodule

// 4.driver：通过virtual interface驱动激励到DUT
class driver;
    virtual counter_if vif;
    transaction tr;
    
    function new(input virtual counter_if vif);
        this.vif = vif;
    endfunction
    
    task run(int n = 10);
        for(int i = 0; i < n; i++) begin
            tr = new();
            assert(tr.randomize());  // 随机化transaction
            $display("tr.load_valid = %0d, tr.load_value = %0d", tr.load_valid, tr.load_value);
            @(posedge vif.clk) begin  // 等待时钟上升沿，同步驱动
                vif.load_valid <= tr.load_valid;
                vif.load_value <= tr.load_value;
            end
        end
    endtask
endclass

// 5.tb_top：测试顶层模块
module tb_top;
    logic       clk = 0;  // 时钟初始化为0，避免X态
    logic       rstn;
    logic [3:0] out;
    
    counter_if dutif(clk);  // 实例化interface
    driver my_driver;
    
    // 主测试流程
    initial begin
        my_driver = new(dutif);    // 创建driver，传入virtual interface
        repeat(2) @(posedge clk);  // 等待2个时钟周期
        @(posedge rstn);           // 等待复位释放
        repeat(5) @(posedge clk);  // 等待5个时钟周期
        my_driver.run(20);         // 运行driver，发送20个随机激励
    end
    
    // 时钟生成
    initial begin
        forever #5 clk = ~clk;     // 周期10ns的时钟
    end
    
    // 复位和仿真控制
    initial begin
        rstn = 1;  repeat(2)  @(posedge clk);  // 初始复位无效
        rstn = 0;  repeat(5)  @(posedge clk);  // 复位有效5个周期
        rstn = 1;  repeat(50) @(posedge clk);  // 复位释放，运行50个周期
        $finish;
    end
   
    // DUT实例化，通过interface连接信号
    counter u_counter (
        .resetn     (rstn),
        .clk        (clk),
        .load_valid (dutif.load_valid),
        .load_value (dutif.load_value),
        .q          (out) 
    );
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// tr.load_valid = 1, tr.load_value = 3
// tr.load_valid = 0, tr.load_value = 7
// tr.load_valid = 1, tr.load_value = 12
// tr.load_valid = 0, tr.load_value = 5
// ...（共20行）
//
// 解析：
// 1. 复位期间：rstn=0，计数器输出q保持0
// 2. 复位释放后：load_valid=1时，q加载load_value的值
//                load_valid=0时，q自增1
// 3. driver通过virtual interface同步驱动激励，每个时钟沿发送一组随机数据
