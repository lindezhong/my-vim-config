package ${group_id}.interfaces.verbdemo1;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import ${group_id}.Application;
import ${group_id}.domain.model.demo1.Demo1.Demo1KeyIdentity;
import ${group_id}.domain.model.demo1.Demo1.Type;
import ${group_id}.infrastructure.advice.Response;
import ${group_id}.interfaces.verbdemo1.dto.DemoDTO;
import ${group_id}.interfaces.verbdemo1.dto.DemoStoreCommand;

// 保证mockMvc能被注入
@AutoConfigureMockMvc
// 确保 Spring 和 JUnit 之间的集成
@ExtendWith(SpringExtension.class)
@SpringBootTest(classes = Application.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
// 确保每个测试之间的上下文完全独立，避免状态共享可能导致的测试错误。
@DirtiesContext(classMode = DirtiesContext.ClassMode.BEFORE_EACH_TEST_METHOD)
public class VerbDemo1ControllerTest {
    
    @Autowired
    private MockMvc mockMvc;

    @Test
    public void findDemo1ByIdentity() throws Exception {
        String responseJson = new ObjectMapper().writeValueAsString(Response.ok(new DemoDTO(&quot;key_test&quot;, Type.TWO)));
        mockMvc.perform(MockMvcRequestBuilders.get(&quot;/model/find&quot;)
            .param(&quot;key&quot;, &quot;key_test&quot;))  // 添加查询参数 param1
            // 断言状态码是200
            .andExpect(MockMvcResultMatchers.status().isOk())
            // 返回值json结构, 对比json完全一致 
            .andExpect(MockMvcResultMatchers.content().json(responseJson))
            // 只断言返回值的json path中的某个值相等
            .andExpect(MockMvcResultMatchers.jsonPath(&quot;$.data.key&quot;).value(&quot;key_test&quot;));
            
    }
    
    @Test
    public void newDemo1() throws Exception {
        String requestJson = new ObjectMapper().writeValueAsString(new DemoStoreCommand(&quot;key&quot;));
        String responseJson = mockMvc.perform(MockMvcRequestBuilders.post(&quot;/model/new&quot;)
            .contentType(MediaType.APPLICATION_JSON)
            .content(requestJson))
            // 断言状态码是200
            .andExpect(MockMvcResultMatchers.status().isOk())
            // 只断言返回值的json path中的json path 存在
            .andExpect(MockMvcResultMatchers.jsonPath(&quot;$.data.identity&quot;).exists())
            // 获取到请求返回值
            .andReturn().getResponse().getContentAsString()
            ;
        Response<Demo1KeyIdentity> response = new ObjectMapper().readValue(responseJson, new TypeReference<Response<Demo1KeyIdentity>>(){});
        // 继续请求
        mockMvc.perform(MockMvcRequestBuilders.get(&quot;/model/find&quot;)
            .param(&quot;key&quot;, response.getData().getIdentity()))  // 添加查询参数 param1
            // 断言状态码是200
            .andExpect(MockMvcResultMatchers.status().isOk())
            // 只断言返回值的json path中的某个值相等
            .andExpect(MockMvcResultMatchers.jsonPath(&quot;$.data.key&quot;).value(response.getData().getIdentity()))
            ;

    }
    
}
