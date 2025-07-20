package ${group_id}.interfaces.verbdemo1;

import java.lang.invoke.MethodHandles;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import ${group_id}.domain.model.demo1.Demo1.Demo1KeyIdentity;
import ${group_id}.infrastructure.error.BusinessException;
import ${group_id}.infrastructure.error.ErrorCode;
import ${group_id}.interfaces.verbdemo1.dto.DemoDTO;
import ${group_id}.interfaces.verbdemo1.dto.DemoQuery;
import ${group_id}.interfaces.verbdemo1.dto.DemoStoreCommand;
import ${group_id}.interfaces.verbdemo1.facade.VerbDemo1Facade;


@RequestMapping(&quot;/model&quot;)
@RestController
public class VerbDemo1Controller {

    private static final Logger log = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

    @Autowired
    public VerbDemo1Facade verbDemo1Facade;



    /**
     * curl -X GET localhost:8080/model/find?key=key
     *
     * 如果是查询, 无副作用的方法用 query结尾的类
     *  
     * @param query
     * @return
     */
    @GetMapping(&quot;/find&quot;)
    public DemoDTO findDemo1ByIdentity(DemoQuery query) {
        return this.verbDemo1Facade.findDemo1ByIdentity(query.getKey());
    }

    
    /**
     * curl -X POST localhost:8080/model/new
     *
     * 如果是有副作用的方法, 会影响到数据, 用 Command 结尾的类
     *
     * @param command
     * @return
     */
    @PostMapping(&quot;new&quot;)
    public Demo1KeyIdentity newDemo1(DemoStoreCommand command) {
        return this.verbDemo1Facade.newDemo1();
    }

    /**
     * 中文: curl -X GET -H &quot;Accept-Language: zh&quot; localhost:8080/model/error
     * 英文: curl -X GET localhost:8080/model/error
     * 异常测试
     */
    @GetMapping(&quot;/error&quot;)
    public DemoDTO error() {
        throw new BusinessException(ErrorCode.SYSTEM_ERROR);
    }



}
