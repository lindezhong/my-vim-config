package ${group_id}.infrastructure.advice;

import java.lang.invoke.MethodHandles;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import ${group_id}.infrastructure.error.BusinessException;

@RestControllerAdvice
public class GlobalErrorAdvice {

    private static final Logger log = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

    @Autowired
    private MessageSource messageSource;

    @ExceptionHandler(value = Exception.class)
    public ResponseEntity<Response<?>> throwable(Exception e) {
        log.error(&quot;Exception&quot;,e);
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            // 未知异常消息不允许抛出任何消息
            .body(Response.error(HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase()));
    }
    

    @ExceptionHandler(value = BusinessException.class)
    public ResponseEntity<Response<?>> throwable(BusinessException e, WebRequest request) {
        log.error(&quot;BusinessException&quot;,e);
        String message = messageSource.getMessage(e.getCode().getErrorCode(), e.getErrorParams(), request.getLocale());
        return ResponseEntity
            .status(e.getCode().getHttpStatus())
            // 未知异常消息不允许抛出任何消息
            .body(Response.error(message));
    }

    @ExceptionHandler(NoResourceFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ResponseEntity<Response<?>> handleNotFound(NoResourceFoundException e) {
        // 对于资源没找到只打印异常信息, 而不要堆栈
        log.error(&quot;{}: {}&quot;,e.getClass(),e.getMessage());
        return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            // 未知异常消息不允许抛出任何消息
            .body(Response.error(HttpStatus.NOT_FOUND, e.getMessage()));
    }

}
