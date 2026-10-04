// 知识点：SystemVerilog 队列(Queue)操作
// 1. 队列声明：元素类型 + 变量名[$]，如 int q[$]
// 2. insert(index, value)：在指定索引位置插入元素
// 3. delete(index)：删除指定索引位置的元素；delete()无参数时删除整个队列
// 4. push_front(value)：在队列头部插入元素
// 5. push_back(value)：在队列尾部插入元素
// 6. pop_front：弹出队列头部元素并返回其值
// 7. pop_back：弹出队列尾部元素并返回其值
// 8. foreach遍历队列
module test (
    int j = 1,
    int q2[$] = {3,4},
    int q[$]  ={0,2,5}
);
    initial begin
        q.insert(1, j); // 在q队列的第二个元素(排列位置从0开始数)之前插入j,
        // 队列q变成{0,1,2,5}
        q.insert(3,q2[0]); //在q队列的第四个元素(排列位置从0开始数)之前
        q.insert(4,q2[1]); // 插入队列q2，队列q变成{0,1,2,3,4,5}
        q.delete(1); //删除第1个元素(排列位置从0开始数), 队列变成{0,2,3,4,5}
        q.push_front(6); //在队列前插入6, q队列变成{6,0,2,3,4,5}
        j = q.pop_back; //把最后一个元素pop出来,赋值给j, j=5, q队列变成{6,0,2,3,4}
        q.push_back(8); //在队列尾部插入8, q队列变成{6,0,2,3,4,8}
        j = q.pop_front; //把第一个元素pop出来,赋值给j, j=6, q队列变成{0,2,3,4,8}
        foreach (q[i])
        $display(q[i]); //打印整个队列
        q.delete(); //删除整个队列
    end

endmodule
