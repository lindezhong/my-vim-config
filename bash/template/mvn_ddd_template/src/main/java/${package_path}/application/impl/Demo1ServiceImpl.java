package ${group_id}.application.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import ${group_id}.application.Demo1Service;
import ${group_id}.domain.model.demo1.Demo1;
import ${group_id}.domain.model.demo1.Demo1Factory;
import ${group_id}.domain.model.demo1.Demo1Repository;

@Service
public class Demo1ServiceImpl implements Demo1Service {

    @Autowired
    private Demo1Factory demo1Factory;

    @Autowired
    private Demo1Repository demo1Repository;

    @Override
    public Demo1 newDemo1() {
        Demo1 demo = this.demo1Factory.newDemo();
        // 对于工厂生成出来的元素需要手动存储
        demo1Repository.store(demo);
        return demo;
    }

    
}
