package ${group_id}.interfaces.verbdemo1.dto;

import java.io.Serializable;

/**
 * 命令请求, 会影响到数据
 * 存储Demo数据命令
 */
public class DemoStoreCommand implements Serializable {

    private String key;

	public DemoStoreCommand(String key) {
		this.key = key;
	}

	public String getKey() {
		return key;
	}
}
