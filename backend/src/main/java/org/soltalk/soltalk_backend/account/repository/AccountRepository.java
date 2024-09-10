package org.soltalk.soltalk_backend.account.repository;

import org.soltalk.soltalk_backend.account.projection.SummaryAccount;
import org.soltalk.soltalk_backend.account.entity.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AccountRepository extends JpaRepository<Account, String> {
    @Query("SELECT a.user.userId, a.accountNo, a.accountType, u.userKey FROM Account a JOIN a.user u")
    List<SummaryAccount> findSummaryAccounts(); // 배치를 실행할 계좌번호 전체 조회
}
