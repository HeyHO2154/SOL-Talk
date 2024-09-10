package org.soltalk.soltalk_backend.financial.repository;

import java.util.List;

import org.soltalk.soltalk_backend.financial.dto.*;
import org.soltalk.soltalk_backend.financial.projection.AccountKey;
import org.soltalk.soltalk_backend.financial.projection.CategorySpendingAvg;
import org.soltalk.soltalk_backend.financial.projection.FinancialTrend;
import org.soltalk.soltalk_backend.financial.projection.UserCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import org.soltalk.soltalk_backend.financial.entity.DailyFinancialSummary;

@Repository
public interface FinancialSummaryRepository extends JpaRepository<DailyFinancialSummary, Integer> {

    @Query(value =  "SELECT category, total_amount " +
                    "FROM (" +
                    "    SELECT d.category as category, SUM(d.total_amount) as total_amount " +
                    "    FROM daily_financial_summary d " +
                    "    WHERE user_id = :userId AND financial_type = 2 " +
                    "    AND financial_date >= NOW() - INTERVAL 30 DAY " +
                    "    GROUP BY d.category " +
                    "    ORDER BY total_amount DESC " +
                    ") AS subquery " +
                    "LIMIT 5",
            nativeQuery = true)
    List<CategorySpendingSummaryDTO> findTop5Categories(@Param("userId") int userId);

    // 최근 한달 지출 상위 5개 카테고리의 동일 연령대 평균 지출 금액
    @Query(value = "WITH user_age_group AS ( "
                + "    SELECT user_no, "
                + "           CASE "
                + "               WHEN YEAR(CURDATE()) - YEAR(birth) + 1 BETWEEN 0 AND 9 THEN '10대 미만' "
                + "               WHEN YEAR(CURDATE()) - YEAR(birth) + 1 BETWEEN 10 AND 19 THEN '10대' "
                + "               WHEN YEAR(CURDATE()) - YEAR(birth) + 1 BETWEEN 20 AND 29 THEN '20대' "
                + "               WHEN YEAR(CURDATE()) - YEAR(birth) + 1 BETWEEN 30 AND 39 THEN '30대' "
                + "               WHEN YEAR(CURDATE()) - YEAR(birth) + 1 BETWEEN 40 AND 49 THEN '40대' "
                + "               ELSE '50대 이상' "
                + "           END AS age_group "
                + "    FROM users "
                + ") "

                + "SELECT do.category AS category, uag.age_group, ROUND(AVG(do.total_amount)) AS avg_amount "
                + "FROM daily_financial_summary do "
                + "JOIN users uo ON uo.user_no = do.user_no "
                + "JOIN user_age_group uag ON uo.user_no = uag.user_no "
                + "WHERE uag.age_group = ( "
                + "        SELECT u.age_group "
                + "        FROM user_age_group u "
                + "        WHERE u.user_no = :userNo "
                + "    ) "
                + "AND do.category IN ( "
                + "                    SELECT category "
                + "                    FROM ( SELECT a.category "
                + "                            FROM ( "
                + "                                SELECT d.category, SUM(d.total_amount) as total_amount "
                + "                                FROM daily_financial_summary d "
                + "                                WHERE d.user_id = :userId AND d.financial_type = 2 "
                + "                                AND d.financial_date >= NOW() - INTERVAL 30 DAY "
                + "                                GROUP BY d.category "
                + "                                ORDER BY SUM(d.total_amount) DESC "
                + "                            ) a "
                + "                        ) AS subquery "
                + "                    LIMIT 5 "
                + "    ) "
                + "GROUP BY do.category, uag.age_group ",
            nativeQuery = true)
    List<CategorySpendingAvg> findTop5CategoriesWithAvg(@Param("userId") int userId);


    // 최근 한달 소비 상위 10개 카테고리의 전월 대비 소비 트렌드 (증감 추이 - 증감률)
    @Query(value = "WITH recent_top10_spending_category AS ( " +
                    "SELECT * " +
                    "FROM ( " +
                    "    SELECT d.category, SUM(d.total_amount) AS total_amount " +
                    "    FROM daily_financial_summary d " +
                    "    WHERE d.user_id = :userId " +
                    "      AND d.financial_type = 2 " +
                    "      AND d.financial_date >= NOW() - INTERVAL 30 DAY " +
                    "    GROUP BY d.category " +
                    "    ORDER BY SUM(d.total_amount) DESC " +
                    "    LIMIT 10 " +
                    ") AS top_spending " +
                    ") " +

                    "SELECT r.category, " +
                    "       r.total_amount AS total_amount, " +
                    "       n.total_amount_before, " +
                    "       r.total_amount - n.total_amount_before AS difference, " +
                    "       CASE WHEN n.total_amount_before = 0 THEN 0 " +
                    "            ELSE ROUND(((r.total_amount - n.total_amount_before)/n.total_amount_before) * 100) " +
                    "       END AS percent_change " +
                    "FROM recent_top10_spending_category r " +
                    "LEFT JOIN ( " +
                    "    SELECT b.category, " +
                    "           SUM(b.total_amount) AS total_amount_before " +
                    "    FROM daily_financial_summary b " +
                    "    WHERE b.user_id = :userId " +
                    "      AND b.financial_type = 2 " +
                    "      AND b.financial_date >= NOW() - INTERVAL 60 DAY " +
                    "      AND b.financial_date < NOW() - INTERVAL 30 DAY " +
                    "      AND b.category IN (SELECT a.category " +
                    "                         FROM recent_top10_spending_category a) " +
                    "    GROUP BY b.category " +
                    ") n ON r.category = n.category " +
                    "ORDER BY r.total_amount DESC",
            nativeQuery = true)
    List<FinancialTrend> getSpendingTrends(@Param("userId") int userId);


    // 최근 7일 카테고리별 소비금액
    @Query(value = "SELECT d.category as category, SUM(d.total_amount) as total_amount " +
                    "FROM daily_financial_summary d " +
                    "WHERE user_id = :userId AND financial_type = 2 " +
                    "AND financial_date >= NOW() - INTERVAL 7 DAY " +
                    "GROUP BY d.category " +
                    "ORDER BY SUM(d.total_amount) DESC"
            , nativeQuery = true)
    List<CategorySpendingSummaryDTO> getLast7DaysSpending(@Param("userId") int userId);


    // 최근 7일 소비 최상위 카테고리
    @Query(value = "SELECT u.user_key, a.account_no, dr.category "
                    + "FROM users u, user_accounts a, ( "
                    + "                                SELECT do.user_id, do.category "
                    + "                                FROM ("
                    + "                                        SELECT d.user_no as user_no "
                    + "                                                ,d.category as category "
                    + "                                        FROM daily_financial_summary d "
                    + "                                        WHERE user_id = :userId "
                    + "                                        AND financial_type = 2 "
                    + "                                        AND financial_date >= SYSDATE - 7 "
                    + "                                        GROUP BY d.user_id, d.category "
                    + "                                        ORDER BY SUM(d.total_amount) DESC "
                    + "                                    ) do "
                    + "                                WHERE ROWNUM = 1 "
                    + "                                ) dr "
                    + "WHERE u.user_id = dr.user_id "
                    + "AND   u.user_id = a.user_id  "
                    + "AND   a.account_type = 2 "
            , nativeQuery = true)
    UserCategory getMostSpendingCategory(@Param("userId") int userId);


    //최근 한달 전월 대비 지출 증감이 가장 큰 카테고리
    @Query(value = "WITH "
                    + "recent_spending_category AS ("
                    + "    SELECT user_id, category, SUM(total_amount) AS total_amount "
                    + "    FROM daily_financial_summary "
                    + "    WHERE financial_type = 2 "
                    + "      AND financial_date >= NOW() - INTERVAL 30 DAY "
                    + "      AND user_id = :userId "  // userId 조건 추가
                    + "    GROUP BY user_id, category "
                    + "), "
                    + "before_spending_category AS ("
                    + "    SELECT user_id, category, SUM(total_amount) AS total_amount "
                    + "    FROM daily_financial_summary "
                    + "    WHERE financial_type = 2 "
                    + "      AND financial_date >= NOW() - INTERVAL 60 DAY "
                    + "      AND financial_date < NOW() - INTERVAL 30 DAY "
                    + "      AND user_id = :userId "  // userId 조건
                    + "    GROUP BY user_id, category "
                    + ") "
                    + "SELECT u.user_key, a.account_no, t.category "
                    + "FROM ("
                    + "    SELECT r.user_id, r.category, "
                    + "           CASE WHEN IFNULL(b.total_amount, 0) = 0 THEN 999 "
                    + "                ELSE (r.total_amount - b.total_amount) * 100 / b.total_amount "
                    + "           END AS growth_rate "
                    + "    FROM recent_spending_category r "
                    + "    LEFT JOIN before_spending_category b ON r.user_id = b.user_id AND r.category = b.category "
                    + "    ORDER BY growth_rate DESC "
                    + ") t "
                    + "JOIN user_accounts a ON t.user_id = a.user_id "
                    + "JOIN users u ON t.user_id = u.user_id "
                    + "WHERE a.account_type = 2 "
                    + "LIMIT 1"
            , nativeQuery = true)
    UserCategory getCategoryWithHighestSpendingGrowth(@Param("userId") int userId);



    // 최근 한달 지출이 가장 많은 카테고리 (1위)
    @Query(value = "SELECT ot.category "
            + "FROM ( "
            + "         SELECT d.category "
            + "         FROM daily_financial_summary d "
            + "         WHERE d.user_id = :userId "
            + "         AND d.financial_type = 2 "
            + "         AND d.financial_date >= NOW() - INTERVAL 30 DAY "
            + "         GROUP BY d.category "
            + "         ORDER BY IFNULL(SUM(d.total_amount), 0) DESC "
            + "         LIMIT 1 "
            + ") ot "
            , nativeQuery = true)
    String findTopCategoryForMonth(@Param("userId") int userId);

    // 최근 한달 지출 상위 3개 카테고리
    @Query(value = "SELECT ot.category "
                    + "FROM ( "
                    + "         SELECT d.category "
                    + "         FROM daily_financial_summary d "
                    + "         WHERE d.user_id = :userId "
                    + "         AND d.financial_type = 2 "
                    + "         AND d.financial_date >= NOW() - INTERVAL 30 DAY "
                    + "         GROUP BY d.category "
                    + "         ORDER BY IFNULL(SUM(d.total_amount), 0) DESC "
                    + "         LIMIT 3 "
                    + ") ot",
            nativeQuery = true)
    String[] findTop3Categories(@Param("userId") int userId);




    // 최근 한달 총 소비 금액
    @Query(value = "SELECT IFNULL(SUM(total_amount), 0) AS total_amount "
            + "FROM daily_financial_summary "
            + "WHERE financial_date >= NOW() - INTERVAL 30 DAY "
            + "AND user_id = :userId",
            nativeQuery = true)
    int deriveTotalSpendingForMonth(@Param("userId") int userId);


    // 금융점수
    @Query(value = "SELECT 50 + (( CASE WHEN r.savings_total_before = 0 THEN 0 "
            + "                    ELSE ROUND (100 * (r.savings_total_after - r.savings_total_before) / r.savings_total_before) "
            + "               END ) "
            + "          +  ( CASE WHEN r.spending_total_before = 0 THEN 0 "
            + "                    ELSE ROUND (100 * (r.spending_total_after - r.spending_total_before) / r.spending_total_before) "
            + "               END ) "
            + "             ) / 4 AS financial_score "
            + "FROM( "
            + "    SELECT SUM( "
            + "                CASE WHEN (financial_type = 1 AND financial_date >= NOW() - INTERVAL 30 DAY) THEN IFNULL(total_amount, 0) "
            + "                     ELSE 0 "
            + "                END "
            + "          ) AS savings_total_after "
            + "        , SUM( "
            + "                CASE WHEN (financial_type = 1 AND financial_date >= NOW() - INTERVAL 60 DAY AND financial_date < NOW() - INTERVAL 30 DAY) THEN IFNULL(total_amount, 0) "
            + "                     ELSE 0 "
            + "                END "
            + "          ) AS savings_total_before "
            + "        , SUM( "
            + "                CASE WHEN (financial_type = 2 AND financial_date >= NOW() - INTERVAL 30 DAY) THEN IFNULL(total_amount, 0) "
            + "                     ELSE 0 "
            + "                END "
            + "          ) AS spending_total_after "
            + "        , SUM( "
            + "                CASE WHEN (financial_type = 2 AND financial_date >= NOW() - INTERVAL 60 DAY AND financial_date < NOW() - INTERVAL 30 DAY) THEN IFNULL(total_amount, 0) "
            + "                     ELSE 0 "
            + "                END "
            + "          ) AS spending_total_before "
            + "    FROM daily_financial_summary "
            + "    WHERE user_id = :userId "
            + ") r "
            , nativeQuery = true)
    int deriveFinancialScore(@Param("userId") int userId);

    // for 지출 총액
    @Query(value = "SELECT u.user_key, a.account_no "
            + "FROM user_accounts a, users u "
            + "WHERE a.user_no = u.user_no "
            + "AND u.user_id = :userId "
            + "AND account_type = 1 " // 저축계좌
            , nativeQuery = true)
    AccountKey findActiveSavingsAccounts(@Param("userId") int userId);

}