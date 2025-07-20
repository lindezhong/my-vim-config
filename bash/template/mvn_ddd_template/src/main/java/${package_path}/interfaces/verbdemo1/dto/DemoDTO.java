package ${group_id}.interfaces.verbdemo1.dto;

import ${group_id}.domain.model.demo1.Demo1.Type;

public class DemoDTO {

    // 正常要是引入需要的全部字段, 现在测试只引入小部分
    
    private String key;

    private Type type;

    public DemoDTO(String key, Type type) {
        this.key = key;
        this.type = type;
    }

    public String getKey() {
        return key;
    }

    public Type getType() {
        return type;
    }

}
