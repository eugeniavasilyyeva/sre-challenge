I also wanted to mention that I am not as familiar with MySQL as I wanted to be. Also, this is the first time when I see such an alert. However, I'll do my best to solve this one. 

```sh
  - alert: MysqlTransactionDeadlock
    expr: increase(mysql_global_status_innodb_row_lock_waits[2m]) > 0
    for: 3m
    labels:
      severity: warning
    annotations:
      dashboard: database-metrics
      summary: 'Mysql Transaction Waits'
    description: 'There are `{{ $value | humanize }}` MySQL connections waiting for a stale transaction to release.'
```

## Description

| Line                                                                                       | Explanation                                                                                                                                                                                                                                  |
|--------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| MysqlTransactionDeadlock                                                                   | most probably indicates the fact that MySQL has encountered a deadlock in a transaction. This could happen when two or more transactions are waiting for each other to release lock on resources, which causes a loop when none can proceed. |
| expr: increase(mysql_global_status_innodb_row_lock_waits[2m]) > 0                          | this must be the event circumstances which trigger the alert. If I understand it correctly, it means that innodb row lock waits has increased in the last 2 minutes and the nuber of blocked transactions is greater than 0.                 |
| for: 3m                                                                                    | most pobably, means that the event happened at least 3 minutes ago and it's time to trigger the alert                                                                                                                                        |
| labels:                                                                                    | some keywords or key-phrases usually assigned here to organize the alerts                                                                                                                                                                    |
| severity: warning                                                                          | specifies the severity of the issue (alert), this one is not critical, only warning.                                                                                                                                                         |
| annotations:                                                                               | readable context shown in dashboards and alerts |
| dashboard: database-metrics                                                                | should refer to the name or ID of the related Grafana dashboard |
| summary: 'Mysql Transaction Waits'                                                         | a title used for notifications or alerts |
| description: 'There are `{{ $value | humanize }}` MySQL connections waiting for a stale transaction to release.' | provides humanized description of the issue with an additional data to help uderstand the issue quickly |

Possible causes of the issue: 
1. Two or more transactions are modifying the same rows and waiting for each other to finish
2. Poorly designed queries or missing indexes can cause excessive row or table lock
3. Higher isolation levels like `SERIALIZE`      
4. Long transactions can also make conflicts 

## Investigation: 

1. Run `SHOW ENGINE INNODB STATUS;` to get details about locks and transactions causing deadlocks.
2. Use `SELECT * FROM INFORMATION_SCHEMA.INNODB_TRX;` to list running transactions.
3. Query `INFORMATION_SCHEMA.INNODB_LOCKS` and `INFORMATION_SCHEMA.INNODB_LOCK_WAITS` for details on locking conflicts.
4. Check slow queries using `SHOW PROCESSLIST;` and analyze queries with `EXPLAIN ANALYZE`.
5. Look for inefficient indexing or long-running transactions.
6. Review application logs to detect transactions that are not being committed or rolled back properly.
7. Use Prometheus and Grafana dashboards to check `mysql_global_status_innodb_row_lock_time_avg` or `mysql_global_status_innodb_row_lock_current` for lock trends.

## Improvements
1. It possibly can be modified to increase convenience and speed of understanding, investigation and fixing the issue.
```sh
description: 'There are {{ $value | humanize }} `MySQL transactions waiting due to row locks. Investigate long-running transactions and potential deadlocks.`'
```
1.1. If we have a guide for such investigations and the alert is clickable (never interacted with one of those, so just an assumption) we can also add a link to it. Also, it may be usable for other alerts, not only this one.
```sh   
description: 'There are {{ $value | humanize }} MySQL transactions waiting due to row locks. [Investigate](https://dev.mysql.com/doc/refman/8.4/en/innodb-deadlocks.html#:~:text=To%20view%20the%20last%20deadlock,to%20the%20mysqld%20error%20log.) long-running transactions and potential deadlocks.
```
2. Reduces unnecessary alerts caused by minor or short-lived lock waits:
```sh   
   expr: increase(mysql_global_status_innodb_row_lock_waits[5m]) > 5
for: 5m
```


Disclaimer: to be honest, I used some ChatGPT to help me understand what it's all about and make it in time. However, it allowed me to quickly adapt to the situation and provide a solution to the case which I never encountered before. I guess, such situations should be pretty common for everyone on new position and ability to learn quickly while providing sustainable solutions can't be considered as a con. 
