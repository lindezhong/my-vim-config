package ${group_id}.interfaces.verbdemo1;

import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping(&quot;/template&quot;)
public class TemplatesController {

    
    @RequestMapping(&quot;/index.htm&quot;)
    public String index(Map<String, Object> model, @RequestParam(&quot;value&quot;) String value) {
        model.put(&quot;value&quot;, value);
        return &quot;index&quot;;
    }
    
}
