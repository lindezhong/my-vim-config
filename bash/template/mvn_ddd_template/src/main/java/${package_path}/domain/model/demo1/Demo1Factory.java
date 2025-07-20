package ${group_id}.domain.model.demo1;

import java.util.Random;

import org.springframework.stereotype.Service;

@Service
public class Demo1Factory {

    /**
     * 测试工厂直接生成出一个固定的数据, 真实情况不是这么做
     *
     * @return
     */
    public Demo1 newDemo() {
        return new Demo1(&quot;key&quot; + new Random().nextInt(1000), Demo1.Type.ONE, 
                new Demo1.Value(&quot;content&quot;, &quot;author&quot;), 
                new Demo1.Relation(&quot;&quot;), new Demo1.TypeSpecification(Demo1.Type.ONE));
    }
}
