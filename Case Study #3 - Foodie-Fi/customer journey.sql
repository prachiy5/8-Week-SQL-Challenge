select * from subscriptions s inner join plans p on s.plan_id=p.plan_id
where customer_id in (1,2,11,13,15,16,18,19)

--Customer 1: Started with a 7-day free trial on 2020-08-01 and then switched to the Basic Monthly plan for $9.90 on 2020-08-08. They seemed happy with the basic features.

--Customer 2: Tried the free trial on 2020-09-20 and quickly upgraded to the Pro Annual plan for $199 on 2020-09-27. They went all in for the best features!

--Customer 11: Signed up for the free trial on 2020-11-19 but didn’t stick around and canceled on 2020-11-26.

--Customer 13: Started with the free trial on 2020-12-15, moved to the Basic Monthly plan for $9.90 on 2020-12-22, and later upgraded to Pro Monthly for $19.90 on 2021-03-29. They seemed to enjoy the service more over time.

--Customer 15: Began with the free trial on 2020-03-17, upgraded to Pro Monthly for $19.90 on 2020-03-24, but canceled on 2020-04-29. They didn’t stick around long.

--Customer 16: Tried the free trial on 2020-05-31, switched to Basic Monthly for $9.90 on 2020-06-07, and later committed to Pro Annual for $199 on 2020-10-21. They became a long-term fan.

--Customer 18: Started with the free trial on 2020-07-06 and upgraded quickly to Pro Monthly for $19.90 on 2020-07-13. They liked the premium features right away.

--Customer 19: Tried the free trial on 2020-06-22, moved to Pro Monthly for $19.90 on 2020-06-29, and later went for Pro Annual at $199 on 2020-08-29. They really valued the full experience
