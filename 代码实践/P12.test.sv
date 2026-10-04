// 知识点：SystemVerilog 随机化(Randomization)
// 1. rand：随机变量，每次randomize()时随机取值，可能重复
// 2. randc：随机循环变量，遍历所有可能值后才重复（cyclic）
// 3. constraint：约束块，限制随机变量的取值范围
// 4. assert(p.randomize())：断言随机化成功，失败时执行else分支
// 5. 数组不能直接用%d打印，需用foreach遍历或%p格式化
class Packet;
    // 随机变量
    rand  bit  [31:0] src, dst, data[8];
    randc bit  [2:0]  kind;
    // 限制源参数的取值
    constraint c
    {
        src > 10;
        src < 15;
    }
endclass

program testgen;
    Packet p;
    
    initial begin
        p = new();  // 创建数据包
        assert(p.randomize())  // 随机化，断言成功
        else $fatal(0, "Packet::randomize failed");
        $display("src  = %0d", p.src);   // 受约束，取值11~14
        $display("dst  = %0d", p.dst);   // 无约束，0~4294967295随机
        $display("kind = %0d", p.kind);  // randc，0~7循环随机
        $write("data = ");
        foreach(p.data[i]) $write("%0d ", p.data[i]);  // 遍历打印数组
        $display();
    end
endprogram

// 运行结果（随机值每次不同，以下为示例）：
// src  = 12
// dst  = 305419896
// kind = 3
// data = 25 100 200 50 150 75 180 10
//
// 解析：
// 1. src受约束 c 限制，取值范围11~14
// 2. dst无约束，全范围随机
// 3. kind为randc，0~7循环出现，不重复直到遍历完所有值
// 4. data为rand数组，8个元素各自独立随机
//
// 改变constraint来改变随机化的值，并观察打印结果是否和预想constraint一致
