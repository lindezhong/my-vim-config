package ${group_id}.domain.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import ${group_id}.domain.model.demo1.Demo1;
import ${group_id}.domain.model.demo1.Demo1Factory;
import ${group_id}.domain.model.demo1.Demo1Repository;

/**
 * service 一般是用动词命名的, 而不是entity来命名 <br />
 * 本来要有接口和实现类, 但为了简化直接定义类, 在实际使用中不应该这样
 */
@Service
public class VerbModel1Service {

    @Autowired
    private Demo1Factory demo1Factory;

    @Autowired
    private Demo1Repository demoRepository;
    
    public Demo1 newDemo() {
        Demo1 demo = demo1Factory.newDemo();
        demoRepository.store(demo);
        return demo;
    }
    
    
}
