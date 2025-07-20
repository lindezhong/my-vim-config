package ${group_id}.interfaces.verbdemo1.facade;

import ${group_id}.domain.model.demo1.Demo1;
import ${group_id}.domain.model.demo1.Demo1Repository;
import ${group_id}.domain.model.demo1.Demo1.Demo1KeyIdentity;
import ${group_id}.domain.service.VerbModel1Service;
import ${group_id}.interfaces.verbdemo1.dto.DemoDTO;

public interface VerbDemo1Facade {

    /**
     * 直接依赖 {@link Demo1Repository} 来查询数据
     *
     * @param demo1KeyIdentityStr
     * @return
     */
    DemoDTO findDemo1ByIdentity(String demo1KeyIdentityStr);
    

    /**
     * 通过依赖 {@link VerbModel1Service} 来查询数据
     *
     * @return
     */
    Demo1KeyIdentity newDemo1();

}

