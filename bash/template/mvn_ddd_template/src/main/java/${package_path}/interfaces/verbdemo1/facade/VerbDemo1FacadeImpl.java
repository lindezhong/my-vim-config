package ${group_id}.interfaces.verbdemo1.facade;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import ${group_id}.domain.model.demo1.Demo1;
import ${group_id}.domain.model.demo1.Demo1.Demo1KeyIdentity;
import ${group_id}.domain.model.demo1.Demo1Repository;
import ${group_id}.domain.service.VerbModel1Service;
import ${group_id}.interfaces.verbdemo1.assembler.DemoDTOAssembler;
import ${group_id}.interfaces.verbdemo1.dto.DemoDTO;

@Service
public class VerbDemo1FacadeImpl implements VerbDemo1Facade {

    @Autowired
    private Demo1Repository demo1Repository;

    @Autowired
    private VerbModel1Service verbdModel1Service;


    @Override
    public DemoDTO findDemo1ByIdentity(String demo1KeyIdentityStr) {
        return DemoDTOAssembler.toDTO(this.demo1Repository.find(new Demo1KeyIdentity(demo1KeyIdentityStr)));
    }

    @Override
    public Demo1KeyIdentity newDemo1() {
        return verbdModel1Service.newDemo().getIdentity();
    }

    
}
