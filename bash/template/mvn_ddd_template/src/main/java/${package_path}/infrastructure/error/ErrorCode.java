package ${group_id}.infrastructure.error;

import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

public enum ErrorCode {

    /**
     * 系统错误
     */
    SYSTEM_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, &quot;system.error&quot;),

    ;

    /**
     * htt状态码
     */
    private HttpStatusCode httpStatus;

    /**
     * 错误编码
     */
    private String errorCode;

    private ErrorCode(HttpStatusCode httpStatus, String errorCode) {
        this.httpStatus = httpStatus;
        this.errorCode = errorCode;
    }

    public HttpStatusCode getHttpStatus() {
        return httpStatus;
    }

    public String getErrorCode() {
        return errorCode;
    }

    
}
