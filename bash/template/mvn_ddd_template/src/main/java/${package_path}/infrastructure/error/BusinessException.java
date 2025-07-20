package ${group_id}.infrastructure.error;

public class BusinessException extends RuntimeException {


    /**
     * 错误编码, 用于构建最终的错误消息
     */
    private ErrorCode code;

    /**
     * 错误参数, 用于构建最终的错误消息
     */
    private Object[] errorParams;

    public BusinessException(ErrorCode code, Object... errorParams) {
        this.code = code;
        this.errorParams = errorParams;
    }


    public BusinessException(Throwable e, ErrorCode code, Object... errorParams) {
        super(e);

        this.code = code;
        this.errorParams = errorParams;
    }


    /**
     * 获取错误编码
     *
     * @return 错误编码
     */
    public ErrorCode getCode() {
        return code;
    }

    /**
     * 获取错误参数
     *
     * @return 错误参数
     */
    public Object[] getErrorParams() {
        return errorParams;
    }


    
}
