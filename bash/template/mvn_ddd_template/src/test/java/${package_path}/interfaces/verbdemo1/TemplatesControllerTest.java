package ${group_id}.interfaces.verbdemo1;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.htmlunit.webdriver.MockMvcHtmlUnitDriverBuilder;
import org.springframework.web.context.WebApplicationContext;

import ${group_id}.Application;

// 保证mockMvc能被注入
@AutoConfigureMockMvc
// 确保 Spring 和 JUnit 之间的集成
@ExtendWith(SpringExtension.class)
@SpringBootTest(classes = Application.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
// 确保每个测试之间的上下文完全独立，避免状态共享可能导致的测试错误。
@DirtiesContext(classMode = DirtiesContext.ClassMode.BEFORE_EACH_TEST_METHOD)
public class TemplatesControllerTest {

    
    @Autowired
    private WebApplicationContext context;

    @LocalServerPort
    private int port;

    protected WebDriver driver;

    @BeforeEach
    public void setup() {
        driver = MockMvcHtmlUnitDriverBuilder.webAppContextSetup(context)
            .build();
    }


    @Test
    public void index() {
        String userInput = &quot;aaa&quot;;
        // 访问页面http://localhost/template/index.htm?value=aaa
        driver.get(String.format(&quot;http://localhost:%d/template/index.htm?value=%s&quot;, port, userInput));
        // 寻找到id为userinput的元素并且比较
        WebElement element = driver.findElement(By.id(&quot;userinput&quot;));
        assertEquals(element.getText(), userInput);
    }
  


    @AfterEach
    public void tearDown() {
        driver.quit();
    }


}
