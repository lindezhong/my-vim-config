package ${group_id}.infrastructure.advice;

import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

/**
 * 用于spring mvc 统一返回格式
 *
 * @param D api返回的数据类型
 */
public class Response<D> {
    
    /**
     * 状态码, 本质上是http状态码
     */
    private HttpStatusCode code;

    /**
     * 报错消息, 只有在非2xx, 即报错的情况下才会有
     */
    private String message;

    /**
     * 数据, 当在返回2xx的时候实际的数据
     */
    private D data;

    protected Response() {
    }

    public Response(HttpStatusCode code, String message, D data) {
        this.code = code;
        this.message = message;
        this.data = data;
    }

    /**
     * 获取状态码, 本质上是http状态码
     *
     * @return 2xx为成功, 5xx为异常 ...
     */
    public int getCode() {
        return code.value();
    }

    /**
     * 报错消息, 只有在非2xx, 即报错的情况下才会有
     *
     * @return 报错消息
     */
    public String getMessage() {
        return message;
    }

    /**
     * 数据, 当在返回2xx的时候实际的数据
     *
     * @return 数据
     */
    public D getData() {
        return data;
    }

    /**
     * 生成一个成功有返回值的Response
     *
     * @param <D> 数据类型
     * @param data 数据
     * @return 成功有返回值的Response
     */
    public static <D> Response<D> ok(D data) {
        return new Response<D>(HttpStatus.OK, null, data);
    }
    
    /**
     * 生成一个成功无返回值的Response
     *
     * @return 无返回值的Response
     */
    public static Response<Void> ok() {
        return new Response<Void>(HttpStatus.OK, null, null);
    }


    /**
     * 生成一个状态码为500的Response
     *
     * @param message 错误消息
     * @return 状态码为500的Response
     */
    public static Response<Void> error(String message) {
        return new Response<Void>(HttpStatus.INTERNAL_SERVER_ERROR, message, null);
    }


    /**
     * 生成一个失败的Response
     *
     * @param code 状态码
     * @param message 错误消息
     * @return 错误的Response
     */
    public static Response<Void> error(HttpStatus code, String message) {
        return new Response<Void>(code, message, null);
    }
    
}
