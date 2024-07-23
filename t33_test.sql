-- insert into ads_sales_management_d
with t11 as (
    -- 经销商基本信息，包括经销商名称、编码、性质、法定代表人、组织编码、系列编码、等级、星级和首次签约日期。
    -- 使用 row_number() 函数对数据进行分区和排序，以确保每个 dealer_code 和 product_series_code 的最新记录。

    select dealer_name
         , dealer_code
         , dealer_nature
         , legal_representative
         , org_code
         , series_code -- 系列编码
         , grade
         , star
         , first_signing_date
    from (select t3.dealer_name
               , t2.dealer_code
               , t3.dealer_nature                                                                                                     -- 经销商性质（0-个人，1-企业）
               , t3.legal_representative
               , t3.org_code
               , t1.product_series_code                                                                                as series_code -- 系列编码
               , t4.grade
               , t4.star
               , t4.first_signing_date                                                                                                -- 首次签约日期
               , row_number() over (partition by t2.dealer_code,t1.product_series_code order by t1.gmt_modified desc ) as rn
          from (select t5.form_no, t0.dealer_code
                from (SELECT a.contract_no
                           , b.dealer_code
                           , MAX(ifnull(a.modify_time, create_time)) as modify_time
                      from dms_contract_apply a
                               left join dms_contract_dealer b
                                         on a.form_no = b.form_no
                      WHERE a.status = 2
                      GROUP BY a.contract_no
                             , b.dealer_code) t0
                         left join dms_contract_apply t5
                                   on t0.contract_no = t5.contract_no
                                       and t0.modify_time = ifnull(t5.modify_time, t5.create_time)) t5
                   left join dms_contract_info t1
                             on t5.form_no = t1.form_no
                   left join dms_contract_dealer t2
                             on t5.form_no = t2.form_no
                                 and t5.dealer_code = t2.dealer_code
                   left join dms_dealer t3
                             on t2.dealer_code = t3.dealer_code
                   left join dms_dealer_star_grade t4
                             on t2.dealer_code = t4.dealer_code
                                 and t1.product_series_code = t4.series_code
          where t2.dealer_code is not null) a
    where rn = 1)
   , return_1 as (select t3.order_no
                       , sum(t3.audit_discount_amount / 100)          as audit_discount_amount          --  审核平价酒退款金额汇总
                       , sum(t3.audit_ad_funds_amount / 100)          as audit_ad_funds_amount          -- 广宣
                       , sum(t3.audit_transfer_discount_amount / 100) as audit_transfer_discount_amount -- 转移平价酒
                       , sum(t3.audit_cash_amount / 100)              as audit_cash_amount              -- 审核现金退款金额
                       , ifnull(sum(t3.audit_discount_amount / 100), 0) +
                         ifnull(sum(t3.audit_ad_funds_amount / 100), 0) +
                         ifnull(sum(t3.audit_transfer_discount_amount / 100), 0) +
                         ifnull(sum(t3.audit_cash_amount / 100), 0)   as return_all
                       , sum(t3.return_num)                           as return_num
                  from dms_sales_return_apply t1
                           left join dms_sales_return_info t2
                                     on t1.form_no = t2.form_no
                           left join dms_sales_return_product_detail t3
                                     on t2.form_no = t3.form_no
                  where status = 2
                    and t1.del = 0
                    and t2.return_type in (1, 2, 6)
                  group by order_no)
   , t22 as (select *
             from (select t1.company_name                                                                                             -- 甲方公司名称
                        , t1.first_party_representative                                                                               -- 甲方代表人
                        , t8.second_party_person                                                                                      -- 乙方公司名称
                        , case
                              when t1.contract_status = 0 then '待生效'
                              when t1.contract_status = 1 then '已生效'
                              when t1.contract_status = 2 then '已过期'
                              when t1.contract_status = 3 then '作废'
                     end                                             as                                               contract_status
                        , case
                              when t1.channel_type = 10 then '团购商'
                              when t1.channel_type = 20 then '渠道商'
                     end                                             as                                               channel_type    -- 签约渠道类型(团购/渠道)
                        , t1.product_series_code                                                                                      -- 签约产品系列编码
                        , t1.contract_no                                                                                              -- 合同编号
                        , t2.dealer_code
                        , case
                              when t2.industry_dealer = 0 then '否'
                              when t2.industry_dealer = 1 then concat('是：', dealer_desc)
                     end                                             as                                               industry_dealer -- 是否行业内经销商
                        , t2.dealer_desc                                                                                              -- 情况说明
                        , t3.province_name
                        , t3.city_name
                        , t3.district_name
                        , t4.status                                                                                                   -- 合同状态
                        , t4.creator
                        , t4.creator_uuid
                        , t4.sale_channel                                                                                             -- 经销渠道
                        , t8.begin_date
                        , t8.end_date
                        , ifnull(t6.target_amount, t9.target_amount) as                                               target_amount   -- 合同目标
                        , row_number() over (partition by product_series_code,t2.dealer_code order by sign_time desc) rn
                        , t7.budget_year
                        , t10.city_manager
                        , t10.regional_manager
                   from (select t5.form_no, t0.dealer_code, t5.contract_no
                         from (SELECT a.contract_no
                                    , b.dealer_code
                                    , MAX(ifnull(a.modify_time, create_time)) as create_time
                               from dms_contract_apply a
                                        left join dms_contract_dealer b
                                                  on a.form_no = b.form_no
                               WHERE a.status = 2
                               GROUP BY a.contract_no
                                      , b.dealer_code) t0
                                  left join dms_contract_apply t5
                                            on t0.contract_no = t5.contract_no
                                                and t0.create_time = ifnull(t5.modify_time, t5.create_time)) t5
                            left join
                        dms_contract_info t1
                        on t5.form_no = t1.form_no
                            left join dms_contract_dealer t2
                                      on t5.form_no = t2.form_no
                                          and t5.dealer_code = t2.dealer_code
                            left join (select form_no
                                            , province_name
                                            , city_name
                                            , GROUP_CONCAT(concat(district_name, '')) as district_name
                                       from dms_contract_marketing_area
                                       group by form_no
                                              , province_name
                                              , city_name) t3
                                      on t5.form_no = t3.form_no
                            left join dms_contract_apply t4
                                      on t5.form_no = t4.form_no
                            left join dms_contract_base_info t8
                                      on t5.form_no = t8.form_no
                            left join (select form_no
                                            , sum(target_amount / 100) as target_amount
                                       from dms_contract_target
                                       group by form_no) t6
                                      on t5.form_no = t6.form_no
                            left join (select contract_no
                                            , sum(target_amount / 100) as target_amount
                                       from dms_contract_target
                                       group by contract_no) t9
                                      on t5.contract_no = t9.contract_no
                            left join budget_year t7
                                      on year(t8.begin_date) >= year(t7.available_begin_date)
                                          or year(t8.end_date) <= year(t7.available_end_date)
                            left join (select t1.form_no
                                            , if(superior_position_name = '城市经理', name, null) as city_manager
                                            , if(superior_position_name = '区域经理', name, null) as regional_manager
                                       from (select t1.*
                                                  , t2.uuid
                                             from (select t1.*
                                                        , t2.superior_position_code
                                                        , t2.superior_position_name
                                                   from dms_contract_apply t1
                                                            left join (select t1.position_code
                                                                            , t1.position_name
                                                                            , t1.superior_position_code
                                                                            , t2.position_name as superior_position_name
                                                                       from md_position t1
                                                                                left join md_position t2
                                                                                          on t1.superior_position_code =
                                                                                             t2.position_code
                                                                                              and
                                                                                             t2.position_name in
                                                                                             ('城市经理',
                                                                                              '区域经理')) t2
                                                                      on t1.position_code = t2.position_code) t1
                                                      left join md_rel_user_position t2
                                                                on t1.superior_position_code = t2.position_code) t1
                                                left join s_user t2
                                                          on t1.uuid = t2.uuid
                                       group by form_no) t10
                                      on t5.form_no = t10.form_no) t
             where rn = 1)
   , t33 as ( -- ⭐
    select dealer_code
         , series_code
         , modify_time                              as time_d
         , budget_year
         , sum(if(order_type = 1, 0, total_amount)) as outer_total_amount -- 签约外销售额
         , sum(if(order_type = 2, 0, total_amount)) as inner_total_amount -- 签约内销售额
         , sum(if(order_type = 1, 0, order_num))    as outer_order_num
         , sum(if(order_type = 2, 0, order_num))    as inner_order_num
    from (select dealer_code
               , order_type
               , series_code
               , budget_year
               , modify_time
               , ifnull(sum(product_total_amount) / 100, 0) + ifnull(sum(custom_total_amount) / 100, 0) -
                 ifnull(sum(return_all), 0) as total_amount
               , count(distinct order_no)   as order_num
          from (select t1.order_no
                     , date(t1.modify_time)                            as modify_time
                     , t2.dealer_code
                     , t2.order_type
                     , ifnull(t2.contract_series_code, t2.series_code) as series_code
                     , t3.total_amount
                     , t4.budget_year
                     , t3.custom_total_amount
                     , t3.product_total_amount
                     , t3.ad_funds_amount
                     , t5.return_all
                from dms_order_apply t1
                         left join dms_order_info t2
                                   on t1.order_no = t2.order_no
                         left join dms_order_payment_info t3
                                   on t1.order_no = t3.order_no
                         left join budget_year t4
                                   on t1.modify_time >= t4.available_begin_date
                                       and t1.modify_time <= t4.available_end_date
                         left join (select t3.order_no
                                         , sum(t3.audit_discount_amount / 100)          as audit_discount_amount          --  审核平价酒退款金额汇总
                                         , sum(t3.audit_ad_funds_amount / 100)          as audit_ad_funds_amount          -- 广宣
                                         , sum(t3.audit_transfer_discount_amount / 100) as audit_transfer_discount_amount -- 转移平价酒
                                         , sum(t3.audit_cash_amount / 100)              as audit_cash_amount              -- 审核现金退款金额
                                         , ifnull(sum(t3.audit_discount_amount / 100), 0) +
                                           ifnull(sum(t3.audit_ad_funds_amount / 100), 0) +
                                           ifnull(sum(t3.audit_transfer_discount_amount / 100), 0) +
                                           ifnull(sum(t3.audit_cash_amount / 100), 0)   as return_all
                                         , sum(t3.return_num)                           as return_num
                                    from dms_sales_return_apply t1
                                             left join dms_sales_return_info t2
                                                       on t1.form_no = t2.form_no
                                             left join dms_sales_return_product_detail t3
                                                       on t2.form_no = t3.form_no
                                    where status = 2
                                      and t1.del = 0
                                      and t2.return_type in (1, 2, 6)
                                    group by order_no) t5
                                   on t1.order_no = t5.order_no
                where t1.status = 2
                  and t1.del = 0) t
          group by dealer_code
                 , order_type
                 , series_code
                 , date(modify_time)
                 , budget_year) t
    group by dealer_code
           , series_code
           , budget_year
           , modify_time)

   , t33_return as (-- 查询 dms_order_adjustments 和 dms_order_adjustments_product_detail 表的所有数据
-- 并通过 order_no 进行关联
    SELECT
         -- 来自 dms_order_adjustments 表的数据
        a.order_no COLLATE utf8mb4_unicode_ci                as order_no                 -- 订单编号
         , a.dealer_code COLLATE utf8mb4_unicode_ci          as dealer_code              -- 经销商编码
         , date(a.apply_time)                                as time_d                   -- 订单时间
         , budget_year                                                                   -- 财年
         , a.contract_series_code COLLATE utf8mb4_unicode_ci AS series_code              -- 签约系列编码
         , a.series_code COLLATE utf8mb4_unicode_ci          as series_code_product      -- 品类编码（用不上）
         , c.specification
         -- , product_level_name                                                       -- 品类名称
         , c.category
         , a.order_type                                                                  -- 订单类型(签约内1/签约外2)
         , (a.custom_total_amount / 100)                     as custom_total_amount      -- 定制费合计
         , (a.total_amount / 100)                            as total_amount             -- 订单总额
         , (a.product_total_amount / 100)                    as product_total_amount     -- 货款总额
         , (a.cash_amount / 100)                             as cash_amount              -- 现金支付
         , (a.discount_amount / 100)                         as discount_amount          -- 平价酒支付
         , (a.transfer_discount_amount / 100)                as transfer_discount_amount -- 转移平价酒支付
         , (a.ad_funds_amount / 100)                         as ad_funds_amount          -- 广宣基金支付
         -- 来自 dms_order_adjustments_product_detail 表的数据
         , b.product_code COLLATE utf8mb4_unicode_ci         as product_code             -- 产品编码
         , c.product_name                                                                -- 产品名称
         , b.product_num                                                                 -- 数量（瓶）
         , b.box_num                                                                     -- 箱数（用不上）
         , b.custom_type                                                                 -- 定制规格
         , b.unit_price
         , t9.类别                                           as product_type
    FROM dms_order_adjustments a
             LEFT JOIN
         dms_order_adjustments_product_detail b
         ON
             a.order_no = b.order_no
             left join md_product c
                       on (b.product_code COLLATE utf8mb4_unicode_ci) = c.product_code
             left join budget_year t4
                       on date(a.apply_time) >= t4.available_begin_date
                           and date(a.apply_time) <= t4.available_end_date
             left join `135t产品对应的系列类别导入数据` t9
                       on (b.product_code COLLATE utf8mb4_unicode_ci) = t9.产品编码)

   , t33_return_test as ( -- 签约内签约外退款数据
    select dealer_code,
           series_code,
           time_d,
           budget_year,
           CAST(IF(order_type = 1, 0, total_amount / 100) AS DECIMAL(19, 4)) AS outer_total_amount,
           CAST(IF(order_type = 2, 0, total_amount / 100) AS DECIMAL(19, 4)) AS inner_total_amount,
           IF(order_type = 1, 0, -1)                                         AS outer_order_num,
           IF(order_type = 2, 0, -1)                                         AS inner_order_num
    from t33_return
    union all
    select dealer_code COLLATE utf8mb4_unicode_ci as dealer_code,
           series_code COLLATE utf8mb4_unicode_ci AS series_code,
           budget_year,
           time_d,
           outer_total_amount,
           inner_total_amount,
           outer_order_num,
           inner_order_num
    FROM t33)

   , t44 as (select dealer_code
                  , series_code
                  , budget_year
                  , sum(conflict_illegal_num) + sum(common_illegal_num) as illegal_num -- 违规次数
             from (select t1.dealer_code
                        , t2.series_code
                        , date(t1.modify_time) as modify_time
                        , t2.order_no
                        , t2.conflict_illegal_num
                        , t2.common_illegal_num
                        , t3.budget_year
                   from dms_illegal_apply t1
                            left join dms_illegal_detail t2
                                      on t1.form_no = t2.form_no
                            left join budget_year t3
                                      on t1.modify_time >= t3.available_begin_date
                                          and t1.modify_time <= t3.available_end_date
                   where t1.status = 2) t
             group by dealer_code
                    , series_code
                    , budget_year)
   , rs_1 as ( -- 经销商基本信息+签约信息
    select t1.*
         , t2.date_value
    from (select t11.dealer_name
               , t11.dealer_code
               , t11.org_code                              -- 大区
               , t11.star                                  -- 星级
               , t11.grade                                 -- 等级
               , t11.series_code
               , t22.channel_type                          -- 签约渠道类型(团购/渠道)
               , t11.first_signing_date                    -- 首次签约日期
               , t11.dealer_nature                         -- 经销商类型
               , t22.budget_year
               , ifnull(t44.illegal_num, 0) as illegal_num -- 违规次数
               , t22.industry_dealer                       -- 代理其他竞争品牌
               , contract_status                           -- 合同状态
               , t22.province_name
               , t22.city_name
               , t22.district_name
               , t22.creator                               -- 城市经理/区域经理/业务员名称
               , t22.creator_uuid
               , t22.sale_channel                          -- 经销区域(渠道)
               , t22.begin_date                            -- 合同开始时间
               , t22.end_date                              -- 合同结束时间
               , t22.company_name                          -- 甲方公司
               , t22.second_party_person                   -- 乙方代表人
               , t22.target_amount                         -- 合同任务量
               , t22.city_manager
               , t22.regional_manager
          from t11
                   left join t22
                             on t11.dealer_code = t22.dealer_code
                                 and t11.series_code = t22.product_series_code
                   left join t44
                             on t11.dealer_code = t44.dealer_code
                                 and t11.series_code = t44.series_code
                                 and t22.budget_year = t44.budget_year
          union all
          select t1.dealer_name
               , t1.dealer_code
               , t3.org_code
               , null
               , null
               , series_code
               , null
               , null
               , null
               , t2.budget_year
               , null
               , null
               , null
               , null
               , null
               , null
               , null
               , null
               , null
               , null
               , null
               , null
               , null
               , null
               , null
               , null
          from out_dealer t1
                   left join budget_year t2
                             on year(date(t1.start_time)) >= year(date(t2.available_begin_date))
                                 or year(date(t1.end_time)) <= year(date(t2.available_end_date))
                   left join dms_dealer t3
                             on t1.dealer_code = t3.dealer_code) t1
             join (select date_value
                   from dim_date
                   where date_value <= date(curdate())) t2
                  on 1 = 1)
   -- =====================================================
   -- 费用（万元）/库存
   , t55 as ( -- 核报费用明细
    select dealer_code
         , series_code
         , modify_time                                                                       as time_d
         , budget_year
         , sum(ifnull(if(activity_type_name = '常规礼品', audit_amount, 0), company_amount)) as '常规礼品核报费用'
         , sum(ifnull(if(activity_type_name = '大型会议', audit_amount, 0),
                      company_amount))                                                       as '大型会议核报费用'
         , sum(ifnull(if(activity_type_name = '地聘人员工资', audit_amount, 0),
                      company_amount))                                                       as '地聘人员工资核报费用'
         , sum(ifnull(if(activity_type_name = '董酒品推会', audit_amount, 0),
                      company_amount))                                                       as '董酒品推会核报费用'
         , sum(ifnull(if(activity_type_name = '公关赠酒', audit_amount, 0),
                      company_amount))                                                       as '公关赠酒核报费用'
         , sum(ifnull(if(activity_type_name = '广告宣传及门头制作', audit_amount, 0),
                      company_amount))                                                       as '广告宣传及门头制作核报费用'
         , sum(ifnull(if(activity_type_name = '回厂游', audit_amount, 0), company_amount))   as '回厂游核报费用'
         , sum(ifnull(if(activity_type_name = '客情旅游', audit_amount, 0),
                      company_amount))                                                       as '客情旅游核报费用'
         , sum(ifnull(if(activity_type_name = '客情维护', audit_amount, 0),
                      company_amount))                                                       as '客情维护核报费用'
         , sum(ifnull(if(activity_type_name = '名酒进名企', audit_amount, 0),
                      company_amount))                                                       as '名酒进名企核报费用'
         , sum(ifnull(if(activity_type_name = '年度秩序奖', audit_amount, 0),
                      company_amount))                                                       as '年度秩序奖核报费用'
         , sum(ifnull(if(activity_type_name = '品鉴活动', audit_amount, 0),
                      company_amount))                                                       as '品鉴活动核报费用'
         , sum(ifnull(if(activity_type_name = '其他活动', audit_amount, 0),
                      company_amount))                                                       as '其他活动核报费用'
         , sum(ifnull(if(activity_type_name = '渠道宣传', audit_amount, 0),
                      company_amount))                                                       as '渠道宣传核报费用'
         , sum(ifnull(if(activity_type_name = '数字宴席', audit_amount, 0),
                      company_amount))                                                       as '数字宴席核报费用'
    from (select dealer_code
               , series_code
               , modify_time
               , activity_type_name
               , budget_year
               , sum(audit_amount / 100)   as audit_amount
               , sum(company_amount / 100) as company_amount
          from (select t1.dealer_code
                     , t1.series_code
                     , date(t2.modify_time) as modify_time
                     , t1.activity_type_name
                     , t1.audit_amount
                     , t1.company_amount
                     , t1.form_no
                     , t3.budget_year
                from tpm_activity_base_info t1
                         left join tpm_manage_info t2
                                   on t1.form_no = t2.form_no
                         left join budget_year t3
                                   on date(t2.modify_time) >= date(t3.available_begin_date)
                                       and date(t2.modify_time) <= date(t3.available_end_date)
                where t2.status in ('1', '5', '2', '10', '20')
                  and t1.form_type = 'pay'
                  and t2.del = 0) t
          group by dealer_code
                 , series_code
                 , modify_time
                 , activity_type_name
                 , budget_year) a
    group by dealer_code
           , series_code
           , modify_time
           , budget_year)
   , t66 as ( -- 活动场次
    select dealer_code
         , series_code
         , modify_time                                                    as time_d
         , budget_year
         , sum(if(activity_type_name = '常规礼品', act_num, 0))           as '常规礼品场次'
         , sum(if(activity_type_name = '大型会议', act_num, 0))           as '大型会议场次'
         , sum(if(activity_type_name = '地聘人员工资', act_num, 0))       as '地聘人员工资场次'
         , sum(if(activity_type_name = '董酒品推会', act_num, 0))         as '董酒品推会场次'
         , sum(if(activity_type_name = '公关赠酒', act_num, 0))           as '公关赠酒场次'
         , sum(if(activity_type_name = '广告宣传及门头制作', act_num, 0)) as '广告宣传及门头制作场次'
         , sum(if(activity_type_name = '回厂游', act_num, 0))             as '回厂游场次'
         , sum(if(activity_type_name = '客情旅游', act_num, 0))           as '客情旅游场次'
         , sum(if(activity_type_name = '客情维护', act_num, 0))           as '客情维护场次'
         , sum(if(activity_type_name = '名酒进名企', act_num, 0))         as '名酒进名企场次'
         , sum(if(activity_type_name = '年度秩序奖', act_num, 0))         as '年度秩序奖场次'
         , sum(if(activity_type_name = '品鉴活动', act_num, 0))           as '品鉴活动场次'
         , sum(if(activity_type_name = '其他活动', act_num, 0))           as '其他活动场次'
         , sum(if(activity_type_name = '渠道宣传', act_num, 0))           as '渠道宣传场次'
         , sum(if(activity_type_name = '数字宴席', act_num, 0))           as '数字宴席场次'
    from ((select t1.dealer_code
                , t1.series_code
                , date(t2.modify_time)       as modify_time
                , t1.activity_type_name
                , t3.budget_year
                , count(distinct t1.form_no) as act_num
           from tpm_activity_base_info t1
                    left join tpm_manage_info t2
                              on t1.form_no = t2.form_no
                    left join budget_year t3
                              on t2.modify_time >= t3.available_begin_date
                                  and t2.modify_time <= t3.available_end_date
           where t2.status in ('1', '5', '2', '10', '20')
             and t1.form_type = 'apply'
             and activity_type_name in
                 ('大型会议', '董酒品推会', '回厂游活动', '客情旅游', '名酒进名企')
             and t2.del = 0
           group by t1.dealer_code
                  , t1.series_code
                  , date(t2.modify_time)
                  , t1.activity_type_name
                  , t3.budget_year)
          union all
          (select t1.dealer_code
                , t1.series_code
                , date(t2.modify_time)       as modify_time
                , t1.activity_type_name
                , t3.budget_year
                , count(distinct t1.form_no) as act_num
           from tpm_activity_base_info t1
                    left join tpm_manage_info t2
                              on t1.form_no = t2.form_no
                    left join budget_year t3
                              on t2.modify_time >= t3.available_begin_date
                                  and t2.modify_time <= t3.available_end_date
           where t2.status in ('1', '5', '2', '10', '20')
             and t1.form_type = 'register'
             and activity_type_name in ('品鉴活动', '数字宴席')
             and t2.del = 0
           group by t1.dealer_code
                  , t1.series_code
                  , date(t2.modify_time)
                  , t1.activity_type_name
                  , t3.budget_year)
          union all
          (select t1.dealer_code
                , t1.series_code
                , date(t2.modify_time)       as modify_time
                , t1.activity_type_name
                , t3.budget_year
                , count(distinct t1.form_no) as act_num
           from tpm_activity_base_info t1
                    left join tpm_manage_info t2
                              on t1.form_no = t2.form_no
                    left join budget_year t3
                              on t2.modify_time >= t3.available_begin_date
                                  and t2.modify_time <= t3.available_end_date
           where t2.status in ('2')
             and t1.form_type = 'pay'
             and activity_type_name in ('公关赠酒', '广告宣传及门头制作', '客情维护', '其他活动', '渠道宣传')
             and t2.del = 0
           group by t1.dealer_code
                  , t1.series_code
                  , date(t2.modify_time)
                  , t1.activity_type_name
                  , t3.budget_year)
          union all
          (select t1.dealer_code
                , t1.series_code
                , date(t2.modify_time)       as modify_time
                , t1.activity_type_name
                , t3.budget_year
                , count(distinct t1.form_no) as act_num
           from tpm_activity_base_info t1
                    left join tpm_manage_info t2
                              on t1.form_no = t2.form_no
                    left join budget_year t3
                              on t2.modify_time >= t3.available_begin_date
                                  and t2.modify_time <= t3.available_end_date
           where activity_type_name in ('常规礼品')
             and t2.del = 0
           group by t1.dealer_code
                  , t1.series_code
                  , date(t2.modify_time)
                  , t1.activity_type_name
                  , t3.budget_year)) a
    group by dealer_code
           , series_code
           , modify_time
           , budget_year)
   , t77 as ( -- 常规预算费用
    select t1.dealer_code
         , t1.series_code
         , t1.budget_year
         , sum(t1.plan_amount / 100) as plan_amount -- 常规预算费用
    from budget_project t1
             left join budget_cost_type t2
                       on t1.cost_type_code = t2.cost_type_code
             left join budget_year t3
                       on t1.modify_time >= t3.available_begin_date
                           and t1.modify_time <= t3.available_end_date
    where t2.cost_type_code = '2001'
    group by t1.dealer_code
           , t1.series_code
           , t1.budget_year)
   , t88 as ( -- 常规实际申请费用
    select t1.dealer_code
         , t1.series_code
         , t1.modify_time             as time_d
         , t3.budget_year
         , sum(t1.apply_amount) / 100 as norm_apply_amount -- 常规申请费用
    from (select ifnull(sum(t2.apply_amount), 0)                    as apply_amount
               , t1.form_no
               , t3.dealer_code
               , t3.series_code
               , ifnull(date(t1.create_time), date(t1.modify_time)) as modify_time
          from tpm_manage_info t1
                   left join tpm_finance_apply_detail t2
                             on t1.form_no = t2.apply_no
                   left join tpm_activity_base_info t3
                             on t1.form_no = t3.form_no
          where t1.status in ('1', '2', '20', '10')
            and t2.branch_channel_code = '3003'
            and t3.form_type = 'apply'
            and t1.del = 0
          group by t3.dealer_code
                 , t3.series_code
                 , ifnull(date(t1.create_time), date(t1.modify_time))
                 , t1.form_no
          union all
          select ifnull(sum(t3.pay_amount), 0) - ifnull(sum(t4.a1), 0) -
                 ifnull(sum(t5.a2), 0)                              as pay_amount
               , t1.form_no
               , t3.dealer_code
               , t3.series_code
               , ifnull(date(t1.create_time), date(t1.modify_time)) as modify_time
          from tpm_manage_info t1
                   left join tpm_finance_apply_detail t2
                             on t1.form_no = t2.apply_no
                   left join tpm_activity_base_info t3
                             on t1.form_no = t3.form_no
                   left join (select apply_no
                                   , item_balance
                                   , apply_amount
                                   , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a1
                              from tpm_finance_apply_detail
                              where branch_channel_code = '3004') t4
                             on t1.form_no = t4.apply_no
                   left join (select apply_no
                                   , item_balance
                                   , apply_amount
                                   , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a2
                              from tpm_finance_apply_detail
                              where branch_channel_code = '3001') t5
                             on t1.form_no = t5.apply_no
          where t1.status in ('5')
            and t2.branch_channel_code = '3003'
            and t3.form_type = 'apply'
            and t1.del = 0
          group by t3.dealer_code
                 , t3.series_code
                 , t1.form_no
                 , ifnull(date(t1.create_time), date(t1.modify_time))) t1
             left join budget_year t3
                       on t1.modify_time >= t3.available_begin_date
                           and t1.modify_time <= t3.available_end_date
    group by t1.dealer_code
           , t1.series_code
           , t1.modify_time
           , t3.budget_year)
   , t88_2 as ( -- 导入金额？
    select t1.dealer_code
         , t1.series_code
         , date(t1.create_time)        as time_d
         , t1.budget_year
         , sum(t2.frozen_amount / 100) as plan_amount -- 导入金额
    from budget_project t1
             left join budget_change_bill_detail t2
                       on t1.budget_address_code = t2.budget_address_code
             left join budget_year t3
                       on t1.modify_time >= t3.available_begin_date
                           and t1.modify_time <= t3.available_end_date
    where t1.cost_type_code = '2001'
      and t1.budget_type_code = '1001'
      and t2.frozen_amount != 0
      and t2.used_amount != 0
    group by t1.dealer_code
           , t1.series_code
           , date(t1.modify_time)
           , t1.budget_year)
   , t88_3 as ( -- 宴席的各种费用？
    select dealer_code
         , series_code
         , time_d
         , if(branch_channel_code = '3003', sum(feast_amount), 0)            as norm_feast_amount
         , if(branch_channel_code = '3004', sum(feast_amount), 0)            as spec_feast_amount
         , if(branch_channel_code in ('3001', '3002'), sum(feast_amount), 0) as overall_feast_amount
    from (select time_d
               , dealer_code
               , order_no
               , series_code
               , branch_channel_code
               , if(bb_status IN (6), sum(pay_amount),
                    sum(company_amount)) as feast_amount -- 家宴金额
          from (SELECT ifnull(date(bb.create_time), date(bb.modify_time)) as time_d
                     , bb.dealer_code                                     as dealer_code
                     , t8.series_code                                     as series_code
                     , bb.status                                          as bb_status
                     , t2.status                                          as t2_status
                     , bb.order_no
                     , sum(bb.company_amount / 100)                       as company_amount
                     , sum(d.apply_amount / 100)                          as apply_amount
                     , if(t2.status = 2, sum(t1.pay_amount / 100), 0)     as pay_amount
                     , d.branch_channel_code
                from tpm_finance_apply_detail d
                         left join tpm_feast_order_info bb
                                   on d.apply_no = bb.order_no
                         left join tpm_finance_pay_detail t1
                                   on t1.apply_no = d.apply_no
                         left join md_product t8
                                   on bb.product_code = t8.product_code
                         left join tpm_manage_info t2
                                   on t1.pay_no = t2.form_no
                WHERE bb.status != '4'
                group by bb.dealer_code
                       , t8.series_code
                       , t2.status
                       , bb.order_no
                       , ifnull(date(bb.create_time), date(bb.modify_time))
                       , bb.status) a
          group by dealer_code
                 , series_code
                 , order_no
                 , time_d) a
    group by dealer_code
           , series_code
           , time_d)
   , t88_1 as ( -- 常规实际核报费用
    select t3.dealer_code
         , t3.series_code
         , ifnull(date(t2.modify_time), date(t2.gmt_create)) as time_d
         , t4.budget_year
         , ifnull(sum(t1.pay_amount / 100), 0) - ifnull(sum(a1 / 100), 0) -
           ifnull(sum(a2 / 100), 0)                             norm_pay_amount -- 常规已核报费用
    from tpm_finance_pay_detail t1
             left join tpm_manage_info t2
                       on t1.pay_no = t2.form_no
             left join tpm_activity_base_info t3
                       on t1.pay_no = t3.form_no
             left join budget_year t4
                       on t2.modify_time >= t4.available_begin_date
                           and t2.modify_time <= t4.available_end_date
             left join (select apply_no
                             , item_balance
                             , apply_amount
                             , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a1
                        from tpm_finance_apply_detail
                        where branch_channel_code = '3004') t5
                       on t2.form_no = t5.apply_no
             left join (select apply_no
                             , item_balance
                             , apply_amount
                             , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a2
                        from tpm_finance_apply_detail
                        where branch_channel_code = '3001') t6
                       on t2.form_no = t6.apply_no
    where t3.form_type = 'pay'
      and t1.branch_channel_code = '3003'
      and t2.status in ('2', '5', '10', '20')
      and t2.del = 0
    group by t3.dealer_code
           , t3.series_code
           , ifnull(date(t2.modify_time), date(t2.gmt_create))
           , t4.budget_year)
   , t133 as ( -- spec_apply_amount -- 实际申请专项费用
    select t1.dealer_code
         , t1.series_code
         , t1.modify_time             as time_d
         , t3.budget_year
         , sum(t1.apply_amount) / 100 as spec_apply_amount -- 实际申请专项费用
    from (select ifnull(sum(t2.apply_amount), 0)                    as apply_amount
               , t1.form_no

               , t3.dealer_code
               , t3.series_code
               , ifnull(date(t1.create_time), date(t1.modify_time)) as modify_time
          from tpm_manage_info t1
                   left join tpm_finance_apply_detail t2
                             on t1.form_no = t2.apply_no
                   left join tpm_activity_base_info t3
                             on t1.form_no = t3.form_no
          where t1.status in ('1', '2', '20', '10')
            and t2.branch_channel_code = '3004'
            and t3.form_type = 'apply'
            and t1.del = 0
          group by t3.dealer_code
                 , t3.series_code
                 , ifnull(date(t1.create_time), date(t1.modify_time))
                 , t1.form_no
          union all
          select ifnull(sum(t3.pay_amount), 0) - ifnull(sum(t4.a1), 0) -
                 ifnull(sum(t5.a2), 0)                              as pay_amount
               , t1.form_no
               , t3.dealer_code
               , t3.series_code
               , ifnull(date(t1.create_time), date(t1.modify_time)) as modify_time
          from tpm_manage_info t1
                   left join tpm_finance_apply_detail t2
                             on t1.form_no = t2.apply_no
                   left join tpm_activity_base_info t3
                             on t1.form_no = t3.form_no
                   left join (select apply_no
                                   , item_balance
                                   , apply_amount
                                   , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a1
                              from tpm_finance_apply_detail
                              where branch_channel_code = '3003') t4
                             on t1.form_no = t4.apply_no
                   left join (select apply_no
                                   , item_balance
                                   , apply_amount
                                   , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a2
                              from tpm_finance_apply_detail
                              where branch_channel_code = '3001') t5
                             on t1.form_no = t5.apply_no
          where t1.status in ('5')
            and t2.branch_channel_code = '3004'
            and t3.form_type = 'apply'
            and t1.del = 0
          group by t3.dealer_code
                 , t3.series_code
                 , t1.form_no
                 , ifnull(date(t1.create_time), date(t1.modify_time))) t1
             left join budget_year t3
                       on t1.modify_time >= t3.available_begin_date
                           and t1.modify_time <= t3.available_end_date
    group by t1.dealer_code
           , t1.series_code
           , t1.modify_time
           , t3.budget_year)
   , t133_1 as ( --  spec_pay_amount -- 已核报专项费用
    select t3.dealer_code
         , t3.series_code
         , ifnull(date(t2.modify_time), date(t2.gmt_create)) as time_d
         , t4.budget_year
         , ifnull(sum(t1.pay_amount / 100), 0) - ifnull(sum(a1 / 100), 0) -
           ifnull(sum(a2 / 100), 0)                             spec_pay_amount -- 已核报专项费用
    from tpm_finance_pay_detail t1
             left join tpm_manage_info t2
                       on t1.pay_no = t2.form_no
             left join tpm_activity_base_info t3
                       on t1.pay_no = t3.form_no
             left join budget_year t4
                       on t2.modify_time >= t4.available_begin_date
                           and t2.modify_time <= t4.available_end_date
             left join (select apply_no
                             , item_balance
                             , apply_amount
                             , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a1
                        from tpm_finance_apply_detail
                        where branch_channel_code = '3003') t5
                       on t2.form_no = t5.apply_no
             left join (select apply_no
                             , item_balance
                             , apply_amount
                             , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a2
                        from tpm_finance_apply_detail
                        where branch_channel_code = '3001') t6
                       on t2.form_no = t6.apply_no
    where t3.form_type = 'pay'
      and t1.branch_channel_code = '3004'
      and t2.status in ('2', '5', '10', '20')
      and t2.del = 0
    group by t3.dealer_code
           , t3.series_code
           , ifnull(date(t2.modify_time), date(t2.gmt_create))
           , t4.budget_year)
   , t99 as ( -- overall_apply_amount -- 实际申请统筹费用
    select t1.dealer_code
         , t1.series_code
         , t1.modify_time             as time_d
         , t3.budget_year
         , sum(t1.apply_amount) / 100 as overall_apply_amount -- 实际申请统筹费用
    from (select ifnull(sum(t2.apply_amount), 0)                    as apply_amount
               , t1.form_no
               , t3.dealer_code
               , t3.series_code
               , ifnull(date(t1.create_time), date(t1.modify_time)) as modify_time
          from tpm_manage_info t1
                   left join tpm_finance_apply_detail t2
                             on t1.form_no = t2.apply_no
                   left join tpm_activity_base_info t3
                             on t1.form_no = t3.form_no
          where t1.status in ('1', '2', '20', '10')
            and t2.branch_channel_code in ('3001', '3002')
            and t3.form_type = 'apply'
            and t1.del = 0
          group by t3.dealer_code
                 , t3.series_code
                 , ifnull(date(t1.create_time), date(t1.modify_time))
                 , t1.form_no
          union all
          select ifnull(sum(t3.pay_amount), 0) - ifnull(sum(t4.a1), 0) -
                 ifnull(sum(t5.a2), 0)                              as pay_amount
               , t1.form_no
               , t3.dealer_code
               , t3.series_code
               , ifnull(date(t1.create_time), date(t1.modify_time)) as modify_time
          from tpm_manage_info t1
                   left join tpm_finance_apply_detail t2
                             on t1.form_no = t2.apply_no
                   left join tpm_activity_base_info t3
                             on t1.form_no = t3.form_no
                   left join (select apply_no
                                   , item_balance
                                   , apply_amount
                                   , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a1
                              from tpm_finance_apply_detail
                              where branch_channel_code = '3003') t4
                             on t1.form_no = t4.apply_no
                   left join (select apply_no
                                   , item_balance
                                   , apply_amount
                                   , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a2
                              from tpm_finance_apply_detail
                              where branch_channel_code = '3004') t5
                             on t1.form_no = t5.apply_no
          where t1.status in ('5')
            and t2.branch_channel_code in ('3001', '3002')
            and t3.form_type = 'apply'
            and t1.del = 0
          group by t3.dealer_code
                 , t3.series_code
                 , t1.form_no
                 , ifnull(date(t1.create_time), date(t1.modify_time))) t1
             left join budget_year t3
                       on t1.modify_time >= t3.available_begin_date
                           and t1.modify_time <= t3.available_end_date
    group by t1.dealer_code
           , t1.series_code
           , t1.modify_time
           , t3.budget_year)
   , t99_1 as (--  overall_pay_amount -- 已核报统筹费用
    select t3.dealer_code
         , t3.series_code
         , ifnull(date(t2.modify_time), date(t2.gmt_create)) as time_d
         , t4.budget_year
         , ifnull(sum(t1.pay_amount / 100), 0) - ifnull(sum(a1 / 100), 0) -
           ifnull(sum(a2 / 100), 0)                             overall_pay_amount -- 已核报统筹费用
    from tpm_finance_pay_detail t1
             left join tpm_manage_info t2
                       on t1.pay_no = t2.form_no
             left join tpm_activity_base_info t3
                       on t1.pay_no = t3.form_no
             left join budget_year t4
                       on t2.modify_time >= t4.available_begin_date
                           and t2.modify_time <= t4.available_end_date
             left join (select apply_no
                             , item_balance
                             , apply_amount
                             , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a1
                        from tpm_finance_apply_detail
                        where branch_channel_code = '3003') t5
                       on t2.form_no = t5.apply_no
             left join (select apply_no
                             , item_balance
                             , apply_amount
                             , ifnull(apply_amount, 0) - ifnull(item_balance, 0) as a2
                        from tpm_finance_apply_detail
                        where branch_channel_code = '3004') t6
                       on t2.form_no = t6.apply_no
    where t3.form_type = 'pay'
      and t1.branch_channel_code in ('3001', '3002')
      and t2.status in ('2', '5', '10', '20')
      and t2.del = 0
    group by t3.dealer_code
           , t3.series_code
           , ifnull(date(t2.modify_time), date(t2.gmt_create))
           , t4.budget_year)
   , t111 as ( -- 平价酒入账金额
    select t1.dealer_code
         , t1.series_code
         , date(t2.create_time) as time_d
         , t3.budget_year
         , IF(t2.usage_status is null
        , sum(t2.amount / 100)
        , 0)                    as amount_1 -- 平价酒入账余额
    from dms_dealer_account t1
             left join dms_acct_discount_detail t2
                       on t1.id = t2.account_id
             left join budget_year t3
                       on t2.entry_time >= t3.available_begin_date
                           and t2.entry_time <= t3.available_end_date
    where account_type = 'discount'
      and usage_status is null
    group by dealer_code
           , series_code
           , date(t2.create_time)
           , budget_year)
   , t111_1 as ( -- 本期平价酒结余
    select t1.dealer_code
         , t1.series_code
         , (avail_amount / 100) as avail_amount -- 平价酒账户余额
    from dms_dealer_account t1
    where account_type = 'discount')
   , t122 as (-- ⭐
    select dealer_code
         , series_code
         , modify_time as time_d
         , budget_year
         , package_specification
         , total_ml
         , unit_price
         , product_num
         , Sales_quantity
         , series_num
         , order_num_1
    from (select dealer_code
               , series_code
               , budget_year
               , modify_time
               , sum(package_specification) as package_specification
               , sum(total_ml)              as total_ml
               , sum(unit_price)            as unit_price     -- 单价
               , sum(product_num)           as product_num    -- 数量
               , sum(Sales_quantity)        as Sales_quantity -- 销售数量——酒
               -- 兼香型产品销售金额
               , sum(series_num)            as series_num     -- 销售数量（公斤）
               , count(distinct order_no)   as order_num_1
          from (select t1.dealer_code
                     , series_code                                                                    -- 名称
                     , product_name
                     , modify_time
                     , order_no
                     , budget_year
                     , category_code
                     , package_specification                                 as package_specification -- 用来换算
                     , if(category_code = '003', (product_num / m1) * m2, 0) as total_ml              -- 规格 * 数量 = 总容量
                     , unit_price / 100                                      as unit_price            -- 单价
                     , product_num                                           as product_num           -- 数量
                     , if(category_code = '003', product_num, 0)             as Sales_quantity        -- 销售数量——酒（瓶数）
                     , round(if(category_code = '003', product_num / package_specification, 0),
                             2)                                              as series_num            -- 销售数量(箱)
                from (select t1.order_no
                           , t2.dealer_code
                           , ifnull(t2.contract_series_code, t2.series_code) as series_code
                           , category_code                                                  -- 003的是酒类 做判断
                           , level_name                                                     -- 名称
                           , t1.product_name
                           , package_specification
                           , t1.specification
                           , t1.unit_price                                                  -- 单价
                           , if(level_name like '%礼盒%', ifnull(product_num, 0) + ifnull(gift_num, 0),
                                product_num) - ifnull(t8.return_num, 0)      as product_num -- 数量
                           , t5.total_amount                                                -- 订单总额
                           , t5.cash_amount                                                 -- 现金支付
                           , t5.discount_amount                                             -- 评价酒支付
                           , t6.budget_year
                           , date(t4.modify_time)                            as modify_time
                           , m1
                           , m2
                           , t8.return_num
                      from dms_order_product_detail t1
                               left join dms_order_info t2
                                         on t1.order_no = t2.order_no
                               left join md_product_level t3
                                         on ifnull(t2.contract_series_code, t2.series_code) = t3.level_code
                               left join dms_order_apply t4
                                         on t1.order_no = t4.order_no
                               left join dms_order_payment_info t5
                                         on t1.order_no = t5.order_no
                               left join budget_year t6
                                         on t4.modify_time >= t6.available_begin_date
                                             and t4.modify_time <= t6.available_end_date
                               left join (select product_code
                                               , SUBSTRING_INDEX(major_rate, '/', 1)  as m1
                                               , SUBSTRING_INDEX(major_rate, '/', -1) as m2
                                          from md_product_sub_unit
                                          where unit_code = 'JL1000002') t7
                                         on t1.product_code = t7.product_code
                               left join (select order_no
                                               , product_code
                                               , sum(return_num) as return_num
                                          from dms_sales_return_product_detail t1
                                                   left join dms_sales_return_info t2
                                                             on t1.form_no = t2.form_no
                                                   left join dms_sales_return_apply t3
                                                             on t1.form_no = t3.form_no
                                          where t2.return_type in (1, 2, 6)
                                            and t3.status = '2'
                                          group by order_no
                                                 , product_code) t8
                                         on t1.order_no = t8.order_no
                                             and t1.product_code = t8.product_code
                      where t4.status = 2
                        and t4.del = 0) t1) a
          group by dealer_code
                 , series_code
                 , modify_time
                 , budget_year) a)
   , t122_return as (select dealer_code
                          , series_code
                          , time_d
                          , budget_year
                          , if(category = '003', product_num, 0)              as package_specification -- 每箱瓶数,暂时未取
                          , if(category = '003', -(product_num / m1) * m2, 0) as total_ml              -- 总容量（计算方式待确认，主单位换算率 主单位/辅单位）
                          , unit_price                                                                 -- 单价（其实没用上）
                          , product_num                                                                -- 数量,所有类别
                          , if(category = '003', -product_num, 0)             as Sales_quantity        -- 销售数量——酒（瓶数）
                          , -box_num                                          as series_num            -- 销售数量(箱)
                          , count(distinct order_no)                          as order_num_1           -- 也不知道这个是做什么的
                     from t33_return t
                              left join md_product_level t1
                                        on series_code = t1.level_code
                              left join (select product_code
                                              , SUBSTRING_INDEX(major_rate, '/', 1)  as m1
                                              , SUBSTRING_INDEX(major_rate, '/', -1) as m2
                                         from md_product_sub_unit
                                         where unit_code = 'JL1000002') t7
                                        on t.product_code = t7.product_code
                     group by dealer_code
                            , series_code
                            , time_d
                            , budget_year
                            , package_specification
                            , total_ml
                            , unit_price
                            , product_num
                            , Sales_quantity
                            , series_num)

   , t122_return_test as (select *
                          from t122
                          union
                          select *
                          from t122_return)
   , t166 as (-- ⭐
    select dealer_code
         , series_code
         , modify_time          as time_d
         , budget_year
         , sum(cash_amount)     as cash_amount
         , sum(discount_amount) as discount_amount
         , sum(total_amount)    as total_amount
    from (select t1.order_no
               , t1.dealer_code
               , date(t4.modify_time)                                        as modify_time
               , ifnull(t1.contract_series_code, t1.series_code)             as series_code
               , t1.contract_series_code
               , t6.budget_year
               , ifnull(t5.cash_amount / 100, 0) + ifnull(t5.custom_total_amount / 100, 0) +
                 ifnull(t5.ad_funds_amount / 100, 0) - ifnull(t7.audit_cash_amount, 0) -
                 ifnull(t7.audit_ad_funds_amount, 0)                         as cash_amount     -- 现金支付
               , ifnull(t5.discount_amount / 100, 0) +
                 ifnull(t5.transfer_discount_amount / 100, 0) - ifnull(t7.audit_discount_amount, 0) -
                 ifnull(t7.audit_transfer_discount_amount, 0)                as discount_amount -- 平价酒支付
               , t3.level_name
               , ifnull(t5.total_amount / 100, 0) - ifnull(t7.return_all, 0) as total_amount
          from dms_order_info t1
                   left join dms_order_apply t4
                             on t1.order_no = t4.order_no
                   left join md_product_level t3
                             on ifnull(t1.contract_series_code, t1.series_code) = t3.level_code
                   left join dms_order_payment_info t5
                             on t1.order_no = t5.order_no
                   left join budget_year t6
                             on t4.modify_time >= t6.available_begin_date
                                 and t4.modify_time <= t6.available_end_date
                   left join (select t3.order_no
                                   , sum(t3.audit_discount_amount / 100)          as audit_discount_amount          --  审核平价酒退款金额汇总
                                   , sum(t3.audit_ad_funds_amount / 100)          as audit_ad_funds_amount          -- 广宣
                                   , sum(t3.audit_transfer_discount_amount / 100) as audit_transfer_discount_amount -- 转移平价酒
                                   , sum(t3.audit_cash_amount / 100)              as audit_cash_amount              -- 审核现金退款金额
                                   , ifnull(sum(t3.audit_discount_amount / 100), 0) +
                                     ifnull(sum(t3.audit_ad_funds_amount / 100), 0) +
                                     ifnull(sum(t3.audit_transfer_discount_amount / 100), 0) +
                                     ifnull(sum(t3.audit_cash_amount / 100), 0)   as return_all
                                   , sum(t3.return_num)                           as return_num
                              from dms_sales_return_apply t1
                                       left join dms_sales_return_info t2
                                                 on t1.form_no = t2.form_no
                                       left join dms_sales_return_product_detail t3
                                                 on t2.form_no = t3.form_no
                              where status = 2
                                and t1.del = 0
                                and t2.return_type in (1, 2, 6)
                              group by order_no) t7
                             on t1.order_no = t7.order_no
          where t4.status = 2
            and t4.del = 0) a
    group by dealer_code
           , series_code
           , modify_time
           , budget_year)
   , t166_return as (select dealer_code
                          , series_code
                          , time_d
                          , budget_year
                          , sum(cash_amount)     as cash_amount
                          , sum(discount_amount) as discount_amount
                          , sum(total_amount)    as total_amount
                     from t33_return
                     group by dealer_code
                            , series_code
                            , time_d
                            , budget_year)
   , t166_return_test as (select *
                          from t166
                          union
                          select *
                          from t166_return)
-- 终端数据，过程指标
   , terminal as ( -- 拿省市区编码  关联 dms_contract_marketing_area 的 省市区 拿form_no去关联 dms_contract_dealer中的 form_no
    select count(distinct terminal_code) as terminal_num -- 终端编码 计算数量
         , dealer_code
         , t4.product_series_code        as series_code
    from md_terminal t1
             left join dms_contract_marketing_area t2
                       on t1.province_code COLLATE utf8mb4_unicode_ci = t2.province_code COLLATE utf8mb4_unicode_ci
                           and t1.city_code COLLATE utf8mb4_unicode_ci = t2.city_code COLLATE utf8mb4_unicode_ci
                           and t1.district_code COLLATE utf8mb4_unicode_ci = t2.district_code COLLATE utf8mb4_unicode_ci
             left join dms_contract_dealer t3
                       on t2.form_no = t3.form_no
             left join dms_contract_info t4
                       on t3.form_no = t4.form_no
    group by dealer_code
           , series_code)

   , keyman as (-- 意见领袖、单位开发
    select dealer_code
         , sum(opinion_leader) as opinion_leader
         , sum(group_buying)   as group_buying
    from (select dealer_code -- 经销商编码  去关联经销商中的dealer_code
               , if(keyman_type = 3, 1, 0)                         opinion_leader
               , if(key_company_type = 2 or keyman_type = 1, 0, 1) group_buying
          from (select id
                     , keyman_type -- 3 是意见领袖
                     , key_company_id
                from md_keyman) md_keyman_tab
                   left join
               (select keyman_id
                     , dealer_code -- 经销商编码  去关联经销商中的dealer_code
                from md_keyman_dealer) keyman_dealer_tab
               on md_keyman_tab.id = keyman_dealer_tab.keyman_id
                   left join
               (select id
                     , key_company_type -- 去除为2的值
                from md_key_company) company_tab
               on md_keyman_tab.key_company_id = company_tab.id) a
    group by dealer_code)
   , t177 as (-- 最近下单时长（天)
    -- 是否半年以上无下单记录
    select t1.dealer_code
         , t1.series_code
         , datediff(date(curdate())
        , date(t1.modify_time)) as order_datediff
         , if(datediff(date(curdate())
                  , date(t1.modify_time)) >= 180
        , '是'
        , '否')                 as half_year_order
    from (select dealer_code
               , series_code
               , modify_time
          from (select t1.dealer_code
                     , ifnull(t1.contract_series_code, t1.series_code)                                                                            as series_code
                     , date(t2.modify_time)                                                                                                       as modify_time
                     , row_number() over (partition by dealer_code, ifnull(t1.contract_series_code, t1.series_code) order by t2.create_time desc) as rn
                from dms_order_info t1
                         left join dms_order_apply t2
                                   on t1.order_no = t2.order_no
                where status = 2
                  and del = 0) a
          where rn = 1) t1)

   , t199 as ( -- 回款现金
    select t1.dealer_code
         , date(t2.entry_time) as time_d
         , t3.budget_year
         , IF(t2.usage_status is null
        , sum(t2.amount / 100)
        , 0)                   as remit_amount -- 回款
    from dms_dealer_account t1
             left join dms_acct_cash_detail t2
                       on t1.id = t2.account_id
             left join budget_year t3
                       on t2.entry_time >= t3.available_begin_date
                           and t2.entry_time <= t3.available_end_date
    where account_type = 'cash'
      and usage_status is null
    group by dealer_code
           , date(t2.entry_time)
           , budget_year)

   , t200 as ( -- 本年首单回款金额
    select dealer_code
         , amount_1 as first_remit_year
    from (select dealer_code
               , time_d
               , amount_1
               , budget_year
               , row_number() over (partition by dealer_code, budget_year order by time_d) as rn
          from (select t1.dealer_code
                     , date(t2.entry_time)                                  as time_d
                     , t3.budget_year
                     , IF(t2.usage_status is null, sum(t2.amount / 100), 0) as amount_1 -- 回款
                from dms_dealer_account t1
                         left join dms_acct_cash_detail t2
                                   on t1.id = t2.account_id
                         left join budget_year t3
                                   on t2.entry_time >= t3.available_begin_date
                                       and t2.entry_time <= t3.available_end_date
                where account_type = 'cash'
                  and usage_status is null
                group by dealer_code
                       , date(t2.entry_time)
                       , budget_year) t1
          where budget_year is not null) a
    where rn = 1)

   , t210 as ( -- 【产品结构】⭐
    select dealer_code
         , modify_time                                                                       as time_d
         , contract_series_code                                                              as series_code
         , sum(if(product_type = '佰草香', total_amount, 0))                                 as 佰草香
         , sum(if(product_type = '国密-G', total_amount, 0))                                 as `国密-G`
         , sum(if(product_type = '珍藏', total_amount, 0))                                   as 珍藏
         , sum(if(product_type = '密藏-D', total_amount, 0))                                 as `密藏-D`
         , sum(if(product_type = '娄山春', total_amount, 0))                                 as 娄山春
         , sum(if(product_series_code = 'CH0418', total_amount, 0))                          as 佰草香礼盒
         , sum(if(product_series_code = 'CH0419', total_amount, 0))                          as 国密礼盒
         , sum(if(product_series_code = 'CH0420', total_amount, 0))                          as 密藏礼盒
         , sum(if(product_series_code = 'CH0421', total_amount, 0))                          as 珍藏礼盒
         , sum(if(type = 1 and product_type not in
                               ('佰草香', '国密-G', '珍藏', '密藏-D', '娄山春') and
                  product_series_code not in ('CH0418', 'CH0419',
                                              'CH0420', 'CH0421'), total_amount, 0))         as 其他（酒类产品）
         , sum(if(product_type = '促销物料', total_amount, 0))                               as 包材物料
         , sum(if(type = 1 and product_series_code in
                               ('娄山春', '密藏-D', '窖藏系列', 'CH0420'), total_amount, 0)) as 兼香型产品销售额
         , sum(if(type = 1 and product_series_code not in
                               ('娄山春', '密藏-D', '窖藏系列', 'CH0420'), total_amount, 0)) as 董香型产品销售额
    from (select dealer_code
               , series_code
               , product_series_code
               , contract_series_code
               , modify_time
               , type
               , product_type
               , ifnull(sum(product_total_amount) / 100, 0) - ifnull(sum(return_all), 0) as total_amount
          from (select t1.order_no
                     , t7.product_code
                     , t8.series_code                    as product_series_code
                     -- 个别产品改成对应的系列
                     , ifnull(t7.product_total_amount, 0) +
                       ifnull(t7.custom_total_amount, 0) as product_total_amount
                     , t3.total_amount
                     , date(t1.modify_time)              as modify_time
                     , t2.dealer_code
                     , t2.order_type
                     , t2.series_code
                     , t2.contract_series_code
                     , t4.budget_year
                     , if(t5.level_code is null, 0, 1)   as type
                     , ifnull(t6.return_all, 0)          as return_all
                     , t9.类别                           as product_type
                from dms_order_apply t1
                         left join dms_order_info t2
                                   on t1.order_no = t2.order_no
                         left join dms_order_product_detail t7
                                   on t1.order_no = t7.order_no
                         left join dms_order_payment_info t3
                                   on t1.order_no = t3.order_no
                         left join budget_year t4
                                   on t1.modify_time >= t4.available_begin_date
                                       and t1.modify_time <= t4.available_end_date
                         left join (select level_code
                                    from md_product_level
                                    where tree_path like '%CH04%') t5
                                   on t2.series_code = level_code
                         left join md_product t8
                                   on t7.product_code = t8.product_code
                         left join `135t产品对应的系列类别导入数据` t9
                                   on t7.product_code = t9.产品编码
                         left join (select t3.order_no
                                         , t3.product_code
                                         , sum(t3.audit_discount_amount / 100)          as audit_discount_amount          --  审核平价酒退款金额汇总
                                         , sum(t3.audit_ad_funds_amount / 100)          as audit_ad_funds_amount          -- 广宣
                                         , sum(t3.audit_transfer_discount_amount / 100) as audit_transfer_discount_amount -- 转移平价酒
                                         , sum(t3.audit_cash_amount / 100)              as audit_cash_amount              -- 审核现金退款金额
                                         , ifnull(sum(t3.audit_discount_amount / 100), 0) +
                                           ifnull(sum(t3.audit_ad_funds_amount / 100), 0) +
                                           ifnull(sum(t3.audit_transfer_discount_amount / 100), 0) +
                                           ifnull(sum(t3.audit_cash_amount / 100), 0)   as return_all
                                         , sum(t3.return_num)                           as return_num
                                    from dms_sales_return_apply t1
                                             left join dms_sales_return_info t2
                                                       on t1.form_no = t2.form_no
                                             left join dms_sales_return_product_detail t3
                                                       on t2.form_no = t3.form_no
                                    where status = 2
                                      and t1.del = 0
                                      and t2.return_type in (1, 2, 6)
                                    group by order_no
                                           , t3.product_code) t6
                                   on t1.order_no = t6.order_no
                                       and t7.product_code = t6.product_code
                where t1.status = 2
                  and t1.del = 0) a
          group by dealer_code
                 , series_code
                 , modify_time
                 , product_series_code
                 , contract_series_code
                 , type) a
    GROUP BY dealer_code
           , contract_series_code
           , modify_time)

   , t210_return as (select dealer_code
                          , time_d
                          , series_code
                          , sum(if(product_type = '佰草香', total_amount, 0))   as 佰草香
                          , sum(if(product_type = '国密-G', total_amount, 0))   as `国密-G`
                          , sum(if(product_type = '珍藏', total_amount, 0))     as 珍藏
                          , sum(if(product_type = '密藏-D', total_amount, 0))   as `密藏-D`
                          , sum(if(product_type = '娄山春', total_amount, 0))   as 娄山春
                          , sum(if(product_code = 'CH0418', total_amount, 0))   as 佰草香礼盒
                          , sum(if(product_code = 'CH0419', total_amount, 0))   as 国密礼盒
                          , sum(if(product_code = 'CH0420', total_amount, 0))   as 密藏礼盒
                          , sum(if(product_code = 'CH0421', total_amount, 0))   as 珍藏礼盒
                          , sum(if(product_type not in
                                   ('佰草香', '国密-G', '珍藏', '密藏-D', '娄山春') and
                                   product_code not in ('CH0418', 'CH0419',
                                                        'CH0420', 'CH0421'), total_amount,
                                   0))                                          as 其他（酒类产品）
                          , sum(if(product_type = '促销物料', total_amount, 0)) as 包材物料
                          , sum(if(product_code in
                                   ('娄山春', '密藏-D', '窖藏系列', 'CH0420'), total_amount,
                                   0))                                          as 兼香型产品销售额
                          , sum(if(product_code not in
                                   ('娄山春', '密藏-D', '窖藏系列', 'CH0420'), total_amount,
                                   0))                                          as 董香型产品销售额
                     from t33_return
                     GROUP BY dealer_code
                            , series_code
                            , time_d)

   , t210_return_test as
    (select *
     from t210
     union
     select *
     from t210_return)
-- -- 退款金额和货权转移，目前都不要
   , t220 as ( --
    select dealer_code
         , series_code
         , time_d
         , ifnull(cash_return_amount
               , 0) + ifnull(discount_return_amount
               , 0) +
           ifnull(ad_return_amount
               , 0) + ifnull(tran_return_amount
               , 0) as return_amount
    from (select dealer_code
               , series_code
               , t1.modify_time                         as time_d
               , sum(t2.cash_amount / 100)              as cash_return_amount     -- 现金退款金额汇总
               , sum(t2.discount_amount / 100)          as discount_return_amount -- 平价酒退款金额汇总
               , sum(t2.ad_funds_amount / 100)          as ad_return_amount       -- 广宣
               , sum(t2.transfer_discount_amount / 100) as tran_return_amount     -- 转移平价酒
          from dms_sales_return_apply t1
                   left join dms_sales_return_info t2
                             on t1.form_no = t2.form_no
                   left join dms_sales_return_product_detail t3
                             on t2.form_no = t3.form_no
          where return_type = 5
            and status = 2
            and t1.del = 0
          group by dealer_code
                 , series_code) a)
   , t230 as ( -- 退款金额和货权转移，目前都不要
    select time_d
         , out_dealer_code as dealer_code
         , series_code
         , ifnull(sum(total_amount / 100)
        , 0)               as trans_amount -- 货权转移
    from (select t1.form_no
               , t1.time_d
               , t2.out_dealer_code
               , t2.series_code
               , t3.order_no
               , t3.total_amount
          from (select form_no
                     , status
                     , (modify_time) as time_d
                from dms_cargo_transfer_apply) t1
                   left join
               -- 货权转移信息
                   (select form_no
                         , case
                               when transfer_type = 1 then '解约转移'
                               when transfer_type = 2 then '借调'
                               when transfer_type = 3 then '其他'
                           end as transfer_type
                         , out_dealer_code -- 转出经销商编码
                         , series_code
                    from dms_cargo_transfer_info) t2
               on t1.form_no = t2.form_no
                   left join
               -- 货权转移-明细
                   (select form_no      -- 表单
                         , order_no     -- 订单号
                         , product_code -- 产品系列
                         , product_name -- 产品名称0
                         , total_amount -- 总金额
                    from dms_cargo_transfer_detail) t3
               on t2.form_no = t3.form_no
          where status = 2
            and transfer_type = '解约转移') a
    group by out_dealer_code
           , series_code
           , time_d)

   , rs as (select rs_1.dealer_name
                 , rs_1.dealer_code
                 , rs_1.date_value                  as time_d
                 , rs_1.budget_year
                 , SUBSTRING_INDEX(t155.org_path
        , '/'
        , 1)                                        AS company                                 -- 公司
                 , SUBSTRING_INDEX(SUBSTRING_INDEX(t155.org_path
                                       , '/'
                                       , 2)
        , '/'
        , -1)                                       AS marketing_center                        -- 营销中心
                 , SUBSTRING_INDEX(SUBSTRING_INDEX(t155.org_path
                                       , '/'
                                       , 3)
        , '/'
        , -1)                                       AS region                                  -- 大区
                 , SUBSTRING_INDEX(SUBSTRING_INDEX(t155.org_path
                                       , '/'
                                       , 4)
        , '/'
        , -1)                                       AS area                                    -- 区域
                 , SUBSTRING_INDEX(SUBSTRING_INDEX(t155.org_path
                                       , '/'
                                       , 5)
        , '/'
        , -1)                                       AS district                                -- 县级
                 , rs_1.star                                                                   -- 星级
                 , rs_1.grade                                                                  -- 等级
                 , t144.level_name
                 , rs_1.channel_type                                                           -- 签约渠道类型(团购/渠道)
                 , rs_1.first_signing_date                                                     -- 首次签约日期
                 , rs_1.dealer_nature                                                          -- 经销商类型
                 , rs_1.contract_status                                                        -- 签约状态
                 , rs_1.illegal_num                                                            -- 违规次数
                 , rs_1.industry_dealer                                                        -- 代理其他竞争品牌
                 , rs_1.province_name
                 , rs_1.city_name
                 , rs_1.district_name
                 , rs_1.creator                                                                -- 城市经理/区域经理/业务员名称
                 , rs_1.creator_uuid
                 , replace(
            replace(replace(replace(replace(replace(replace(rs_1.sale_channel, '1', '团购'), '2', '酒店'),
                                            '3', '商超'), '4', '名烟名酒店'), '5',
                            '经销商虚拟直营'), '6', '宴席'), '99',
            '其他')                                 as sale_channel                            -- 经销区域(渠道)
                 , rs_1.begin_date                                                             -- 合同开始时间
                 , rs_1.end_date                                                               -- 合同结束时间
                 , rs_1.company_name                                                           -- 甲方公司
                 , rs_1.second_party_person                                                    -- 乙方代表人
                 , rs_1.target_amount                                                          -- 合同任务量
                 , rs_1.city_manager
                 , rs_1.regional_manager
                 , t33_return_test.outer_total_amount                                                      -- 签约外销售额⭐
                 , t33_return_test.inner_total_amount                                          -- 签约内销售额⭐
                 , t33_return_test.outer_order_num                                             -- 签约外下单次数⭐
                 , t33_return_test.inner_order_num                                             -- 签约内下单次数⭐
                 , t55.常规礼品核报费用
                 , t55.大型会议核报费用
                 , t55.地聘人员工资核报费用
                 , t55.董酒品推会核报费用
                 , t55.公关赠酒核报费用
                 , t55.广告宣传及门头制作核报费用
                 , t55.回厂游核报费用
                 , t55.客情旅游核报费用
                 , t55.客情维护核报费用
                 , t55.名酒进名企核报费用
                 , t55.年度秩序奖核报费用
                 , t55.品鉴活动核报费用
                 , t55.其他活动核报费用
                 , t55.渠道宣传核报费用
                 , t55.数字宴席核报费用
                 , t66.常规礼品场次
                 , t66.大型会议场次
                 , t66.地聘人员工资场次
                 , t66.董酒品推会场次
                 , t66.公关赠酒场次
                 , t66.广告宣传及门头制作场次
                 , t66.回厂游场次
                 , t66.客情旅游场次
                 , t66.客情维护场次
                 , t66.名酒进名企场次
                 , t66.年度秩序奖场次
                 , t66.品鉴活动场次
                 , t66.其他活动场次
                 , t66.渠道宣传场次
                 , t66.数字宴席场次
                 , t77.plan_amount                                                             -- 常规预算费用
                 , ifnull(t88.norm_apply_amount, 0) + ifnull(t88_2.plan_amount, 0) +
                   ifnull(t88_3.norm_feast_amount, 0)                                          -- 实际申请常规费用
                 , ifnull(t88_1.norm_pay_amount, 0) + ifnull(t88_2.plan_amount, 0)             -- 已核报常规费用
                 , ifnull(t88.norm_apply_amount, 0) + ifnull(t88_3.norm_feast_amount, 0) -
                   ifnull(t88_1.norm_pay_amount, 0) as norm_no_amount                          -- 未核报常规费用
                 , ifnull(t133.spec_apply_amount, 0) + ifnull(t88_3.spec_feast_amount, 0)      -- 实际申请专项费用
                 , ifnull(t133_1.spec_pay_amount, 0)                                           -- 已核报专项费用
                 , ifnull(t133.spec_apply_amount, 0) + ifnull(t88_3.spec_feast_amount, 0) -
                   ifnull(spec_pay_amount, 0)       as spec_no_amount                          -- 未核报专项费用
                 , ifnull(t99.overall_apply_amount, 0) + ifnull(t88_3.overall_feast_amount, 0) -- 实际申请统筹费用
                 , ifnull(t99_1.overall_pay_amount, 0)                                         -- 已核报统筹费用
                 , ifnull(t99.overall_apply_amount, 0) + ifnull(t88_3.overall_feast_amount, 0) -
                   ifnull(overall_pay_amount, 0)    as overall_no_amount                       -- 未核报统筹费用
                 , t111_1.avail_amount                                                         -- 平价酒账户余额
                 , t111.amount_1                                                               -- 平价酒入账余额
                 , t122_return_test.package_specification                                      -- 用来换算
                 , t122_return_test.total_ml                                                   -- 规格 * 数量 = 总容量⭐
                 , t122_return_test.unit_price                                                 -- 单价
                 , t122_return_test.product_num                                                -- 数量
                 , t166_return_test.total_amount                                               -- 订单总额
                 , t166_return_test.cash_amount                                                -- 现金支付⭐
                 , t166_return_test.discount_amount                                            -- 平价酒支付⭐
                 , t199.remit_amount                                                           -- 回款金额
                 , 0                                                                           -- 银企直连金额
                 , t200.first_remit_year                                                       -- 首次回款金额
                 , t122_return_test.Sales_quantity                                             -- 销售数量——酒⭐
                 , t210_return_test.董香型产品销售额                                           -- ⭐
                 , t210_return_test.兼香型产品销售额                                           -- ⭐
                 , t122_return_test.series_num                                                 -- 销售数量（件）⭐
                 , terminal.terminal_num                                                       -- 终端数
                 , keyman.opinion_leader                                                       -- 意见领袖
                 , keyman.group_buying                                                         -- 团购单位
                 , t177.order_datediff                                                         -- 最近下单时常
                 , t177.half_year_order                                                        -- 是否半年以内无下单记录
                 , t210_return_test.佰草香
                 , t210_return_test.`国密-G`
                 , t210_return_test.珍藏
                 , t210_return_test.`密藏-D`
                 , t210_return_test.娄山春
                 , t210_return_test.佰草香礼盒
                 , t210_return_test.国密礼盒
                 , t210_return_test.密藏礼盒
                 , t210_return_test.珍藏礼盒
                 , t210_return_test.其他（酒类产品）
                 , t210_return_test.包材物料
                 , t220.return_amount
                 , t230.trans_amount
            from rs_1
                     left join t33
                               on rs_1.dealer_code = t33_return_test.dealer_code
                                   and rs_1.series_code = t33_return_test.series_code
                                   and rs_1.budget_year = t33_return_test.budget_year
                                   and date(rs_1.date_value) = date(t33_return_test.time_d)
                     left join t55
                               on rs_1.dealer_code = t55.dealer_code
                                   and rs_1.series_code = t55.series_code
                                   and rs_1.budget_year = t55.budget_year
                                   and date(rs_1.date_value) = date(t55.time_d)
                     left join t66
                               on rs_1.dealer_code = t66.dealer_code
                                   and rs_1.series_code = t66.series_code
                                   and rs_1.budget_year = t66.budget_year
                                   and date(rs_1.date_value) = date(t66.time_d)
                     left join t77
                               on rs_1.dealer_code = t77.dealer_code
                                   and rs_1.series_code = t77.series_code
                                   and rs_1.budget_year = t77.budget_year
                     left join t88
                               on rs_1.dealer_code = t88.dealer_code
                                   and rs_1.series_code = t88.series_code
                                   and rs_1.budget_year = t88.budget_year
                                   and date(rs_1.date_value) = date(t88.time_d)
                     left join t99
                               on rs_1.dealer_code = t99.dealer_code
                                   and rs_1.series_code = t99.series_code
                                   and rs_1.budget_year = t99.budget_year
                                   and date(rs_1.date_value) = date(t99.time_d)
                     left join t133
                               on rs_1.dealer_code = t133.dealer_code
                                   and rs_1.series_code = t133.series_code
                                   and rs_1.budget_year = t133.budget_year
                                   and date(rs_1.date_value) = date(t133.time_d)
                     left join t111
                               on rs_1.dealer_code = t111.dealer_code
                                   and rs_1.series_code = t111.series_code
                                   and rs_1.budget_year = t111.budget_year
                                   and date(rs_1.date_value) = date(t111.time_d)
                     left join t122
                               on rs_1.dealer_code = t122_return_test.dealer_code
                                   and rs_1.series_code = t122_return_test.series_code
                                   and rs_1.budget_year = t122_return_test.budget_year
                                   and date(rs_1.date_value) = date(t122_return_test.time_d)
                     left join md_product_level t144
                               on rs_1.series_code = t144.level_code
                     left join md_organization t155
                               on rs_1.org_code = t155.org_code
                     left join t166
                               on rs_1.dealer_code = t166_return_test.dealer_code
                                   and rs_1.series_code = t166_return_test.series_code
                                   and rs_1.budget_year = t166_return_test.budget_year
                                   and date(rs_1.date_value) = date(t166_return_test.time_d)
                     left join terminal
                               on rs_1.dealer_code = terminal.dealer_code
                                   and rs_1.series_code = terminal.series_code
                     left join keyman
                               on rs_1.dealer_code = keyman.dealer_code
                     left join t177
                               on rs_1.dealer_code = t177.dealer_code
                                   and rs_1.series_code = t177.series_code
                     left join t199
                               on rs_1.dealer_code = t199.dealer_code
                                   and date(rs_1.date_value) = date(t199.time_d)
                     left join t200
                               on rs_1.dealer_code = t200.dealer_code
                     left join t210
                               on rs_1.dealer_code = t210_return_test.dealer_code
                                   and date(rs_1.date_value) = date(t210_return_test.time_d)
                                   and rs_1.series_code = t210_return_test.series_code
                     left join t88_1
                               on rs_1.dealer_code = t88_1.dealer_code
                                   and rs_1.series_code = t88_1.series_code
                                   and rs_1.budget_year = t88_1.budget_year
                                   and date(rs_1.date_value) = date(t88_1.time_d)
                     left join t133_1
                               on rs_1.dealer_code = t133_1.dealer_code
                                   and rs_1.series_code = t133_1.series_code
                                   and rs_1.budget_year = t133_1.budget_year
                                   and date(rs_1.date_value) = date(t133_1.time_d)
                     left join t99_1
                               on rs_1.dealer_code = t99_1.dealer_code
                                   and rs_1.series_code = t99_1.series_code
                                   and rs_1.budget_year = t99_1.budget_year
                                   and date(rs_1.date_value) = date(t99_1.time_d)
                     left join t111_1
                               on rs_1.dealer_code = t111_1.dealer_code
                                   and rs_1.series_code = t111_1.series_code
                     left join t220
                               on rs_1.dealer_code = t220.dealer_code
                                   and rs_1.series_code = t220.series_code
                                   and date(rs_1.date_value) = date(t220.time_d)
                     left join t230
                               on rs_1.dealer_code = t230.dealer_code
                                   and rs_1.series_code = t230.series_code
                                   and date(rs_1.date_value) = date(t230.time_d)
                     left join t88_2
                               on rs_1.dealer_code = t88_2.dealer_code
                                   and rs_1.series_code = t88_2.series_code
                                   and date(rs_1.date_value) = date(t88_2.time_d)
                     left join t88_3
                               on rs_1.dealer_code = t88_3.dealer_code
                                   and rs_1.series_code = t88_3.series_code
                                   and date(rs_1.date_value) = date(t88_3.time_d))
select *
from rs;






