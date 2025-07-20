package ${group_id}.interfaces.verbdemo1.assembler;

import ${group_id}.domain.model.demo1.Demo1;
import ${group_id}.interfaces.verbdemo1.dto.DemoDTO;

/**
 * 转换器
 */
public class DemoDTOAssembler {

    public static DemoDTO toDTO(Demo1 demo) {
        return new DemoDTO(demo.getKey(), demo.getType());
    }

    
}
