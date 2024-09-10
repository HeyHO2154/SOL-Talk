package org.soltalk.soltalk_backend.domain.account.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SummaryAccountData {
    private int userNo;
    private String userKey;
    private String accountNo;
    private int accountType;
}
