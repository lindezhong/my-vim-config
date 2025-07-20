package ${group_id}.interfaces.verbdemo1.dto;

import java.io.Serializable;

/**
 * 查询请求, 不影响到数据
 */
public class DemoQuery implements Serializable {

    private String key;

	public DemoQuery(String key) {
		this.key = key;
	}

	public String getKey() {
		return key;
	}
}
