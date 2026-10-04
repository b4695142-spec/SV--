// 知识点：SystemVerilog 动态数组约束与数组方法
// 1. rand int len[]：随机动态数组，大小和元素均可随机化
// 2. foreach(len[i])：约束数组中每个元素
// 3. inside {[1:255]}：约束元素取值在1~255之间
// 4. len.sum()：数组求和方法，计算所有元素之和
// 5. len.size()：获取动态数组大小，可约束数组长度范围
// 6. 多约束同时生效：元素范围、数组大小、求和上限均需满足
class good_sum;
    rand int len[];
    constraint c_len
    {
        foreach(len[i]) len[i] inside {[1:255]};  // 每个元素在1~255之间
        len.sum() < 1024;                         // 所有元素之和小于1024
        len.size() inside {[1:8]};               // 数组大小1~8
    }
    
    function void display();
        $write("sum=%4d", len.sum());            // 打印元素之和
        foreach(len[i]) $write("%4d", len[i]);   // 打印每个元素
        $display();
    endfunction
endclass

module test;
    good_sum gs;

    initial begin
        gs = new();
        repeat(5) begin
            assert(gs.randomize());  // 随机化
            gs.display();            // 打印结果
        end
    end
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// sum= 100   10   20   30   40
// sum= 500   50  100  150  200
// sum=  15    1    2    3    4    5
// sum= 800  200  200  200  200
// sum=   6    1    2    3
//
// 解析：
// 每次随机化，数组大小在1~8之间，每个元素在1~255之间
// 所有元素之和始终小于1024
