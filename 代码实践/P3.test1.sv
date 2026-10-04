// 知识点：SystemVerilog 定长数组(Fixed-size Array)操作
// 1. 定长数组声明：类型 [位宽] 变量名[大小]，如 bit [31:0] src[5]
// 2. 数组初始化：使用 '{值列表}，如 '{0,1,2,3,4}
// 3. 数组整体赋值：dst = src，将src整个数组复制给dst
// 4. 数组整体比较：使用 == 或 != 可直接比较两个数组
// 5. 单个元素访问：通过索引 src[0] 访问
module test;
    bit [31:0] src[5] = '{0,1,2,3,4},
               dst[5] = '{5,4,3,2,1};

    initial begin
        if (src==dst) $display("src == dst");
        else $display("src != dst");

        dst = src;
        src[0] = 5;

        $display("src %s dst",(src==dst) ? "==" : "!=");

        // 定长数组不支持切片比较，改用循环逐个比较子区间
        begin
            bit equal = 1;
            for (int i = 1; i <= 4; i++) begin
                if (src[i] != dst[i]) begin
                    equal = 0;
                    break;
                end
            end
            $display("src[1:4] %s dst[1:4]", equal ? "==" : "!=");
        end
    end
endmodule
