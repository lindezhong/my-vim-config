package ${group_id}.infrastructure.advice;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.springframework.core.MethodParameter;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.lang.Nullable;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;

@RestControllerAdvice
public class ResponseAdvice implements ResponseBodyAdvice<Object> {

    /**
     * 不支持转换的返回类型
     */
    private static final Set<Class<?>> NO_SUPPORTED_CLASSES = new HashSet<>(
            Arrays.asList(
                ResponseEntity.class,
                Response.class,
                String.class,
                byte[].class,
                Resource.class,
                javax.xml.transform.Source.class
    ));

    @Override
    public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType) {
        return !NO_SUPPORTED_CLASSES.contains(returnType.getParameterType());
    }

    @Override
    @Nullable
    public Object beforeBodyWrite(@Nullable Object body, MethodParameter returnType, MediaType selectedContentType,
            Class<? extends HttpMessageConverter<?>> selectedConverterType, ServerHttpRequest request,
            ServerHttpResponse response) {
        return Response.ok(body);
    }

    
}
