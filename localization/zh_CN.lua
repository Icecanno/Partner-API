return {
    descriptions = {
        Partner={
            pnr_partner_jimbo={
                name = "金宝伙伴",
                text = {
                    "每次出牌",
                    "获得{C:chips}+#2#{}筹码",
                    "{C:inactive}（当前为{C:chips}+#1#{C:inactive}筹码）",
                },
                unlock={
                    "使用{C:attention}小丑",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_mute={
                name = "哑剧伙伴",
                text = {
                    "重复触发手中",
                    "{C:attention}最后一张{}牌的能力",
                },
                unlock={
                    "使用{C:attention}哑剧演员",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_mute_1={
                name = "哑剧伙伴",
                text = {
                    "手中{C:attention}最后一张{}牌",
                    "能力额外触发{C:attention}#1#{}次",
                },
                unlock={
                    "使用{C:attention}哑剧演员",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_unite={
                name = "拳头伙伴",
                text = {
                    "手中点数{C:attention}最大{}的牌",
                    "会给予{X:mult,C:white}X#1#{}倍率",
                },
                unlock={
                    "使用{C:attention}致胜之拳",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_hatch={
                name = "鸡蛋伙伴",
                text = {
                    "回合结束时",
                    "令所有{C:attention}小丑牌{}",
                    "{C:attention}售价{}增加{C:money}$#1#{}",
                },
                unlock={
                    "使用{C:attention}鸡蛋",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_steal={
                name = "窃贼伙伴",
                text = {
                    "选择{C:attention}Boss盲注{}后",
                    "出牌次数{C:blue}+#1#{}",
                },
                unlock={
                    "使用{C:attention}窃贼",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_steal_1={
                name = "窃贼伙伴",
                text = {
                    "选择{C:attention}盲注{}后",
                    "弃牌次数{C:red}+#1#{}",
                },
                unlock={
                    "使用{C:attention}窃贼",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_pale={
                name = "无面伙伴",
                text = {
                    "每弃掉{C:attention}#1#{C:inactive}[#2#]{}张{C:attention}人头牌{}",
                    "获得{C:money}$#3#{}",
                },
                unlock={
                    "使用{C:attention}无面小丑",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_penalty={
                name = "红牌伙伴",
                text = {
                    "跳过{C:attention}补充包{}时",
                    "返还{C:attention}一半{}购买费用",
                },
                unlock={
                    "使用{C:attention}红牌",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_penalty_1={
                name = "红牌伙伴",
                text = {
                    "跳过{C:attention}补充包{}时",
                    "返还{C:attention}全额{}购买费用",
                },
                unlock={
                    "使用{C:attention}红牌",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_fantasy={
                name = "幻觉伙伴",
                text = {
                    "打开{C:attention}补充包{}有{C:green}#1#/#2#{}几率",
                    "生成一张{C:spectral}幻灵牌{}",
                    "{C:inactive}（必须有空间）",
                },
                unlock={
                    "使用{C:attention}幻觉",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_oracle={
                name = "占卜伙伴",
                text = {
                    "每{C:attention}#1#{C:inactive}[#2#]{}个商店",
                    "额外上架一个",
                    "免费的{C:tarot,T:p_arcana_normal_1}秘术包{}",
                },
                unlock={
                    "使用{C:attention}占卜师",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_oracle_1={
                name = "占卜伙伴",
                text = {
                    "每个商店额外上架",
                    "一个免费{C:tarot,T:p_arcana_normal_1}秘术包{}",
                },
                unlock={
                    "使用{C:attention}占卜师",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_finesse={
                name = "杂耍伙伴",
                text = {
                    "选择{C:attention}盲注{}后",
                    "若{C:attention}小丑牌槽位{}未满",
                    "本回合手牌上限{C:attention}+#1#{}",
                },
                unlock={
                    "使用{C:attention}杂耍师",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_finesse_1={
                name = "杂耍伙伴",
                text = {
                    "选择{C:attention}盲注{}后",
                    "本回合手牌上限{C:attention}+#1#{}",
                },
                unlock={
                    "使用{C:attention}杂耍师",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_gilded={
                name = "黄金伙伴",
                text = {
                    "回合结束时获得{C:money}$#1#{}",
                    "击败{C:attention}Boss盲注{}后",
                    "这一金额增加{C:money}$#2#{}",
                },
                unlock={
                    "使用{C:attention}黄金小丑",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_batter={
                name = "棒球伙伴",
                text = {
                    "每张{C:green}罕见{}小丑牌",
                    "会给予{C:mult}+#1#{}倍率",
                },
                unlock={
                    "使用{C:attention}棒球卡",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_bargain={
                name = "交易伙伴",
                text = {
                    "每回合{C:attention}最后一次{}弃牌",
                    "若只有一张牌",
                    "则将其摧毁并失去{C:money}$#1#{}",
                },
                unlock={
                    "使用{C:attention}交易卡",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_bargain_1={
                name = "交易伙伴",
                text = {
                    "每回合{C:attention}最后一次{}弃牌",
                    "若不超过两张牌",
                    "则摧毁{C:attention}所有{}弃掉的牌",
                },
                unlock={
                    "使用{C:attention}交易卡",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_memory={
                name = "闪示伙伴",
                text = {
                    "令每个商店第一次",
                    "{C:green}重掷{}后的第一张牌",
                    "变成{C:dark_edition,T:memory_negative}负片{}版本",
                },
                unlock={
                    "使用{C:attention}闪示卡",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_memory_1={
                name = "闪示伙伴",
                text = {
                    "令每个商店第一次",
                    "{C:green}重掷{}后的第一张牌",
                    "变成免费的{C:dark_edition}负片{}版本",
                },
                unlock={
                    "使用{C:attention}闪示卡",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_stoke={
                name = "篝火伙伴",
                text = {
                    "下次出牌{X:mult,C:white}X#1#{}倍率",
                    "点击支付{C:money}$#3#{}",
                    "以提高{X:mult,C:white}X#2#{}倍率",
                },
                unlock={
                    "使用{C:attention}篝火",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_verify={
                name = "证书伙伴",
                text = {
                    "点击支付{C:money}$#1#{}",
                    "为选中的{C:attention}1{}张牌",
                    "添加随机{C:attention}蜡封{}",
                },
                unlock={
                    "使用{C:attention}证书",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_jump={
                name = "回溯伙伴",
                text = {
                    "跳过{C:attention}盲注{}时",
                    "额外获得{C:attention}#1#{}份标签",
                },
                unlock={
                    "使用{C:attention}回溯",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_jump_1={
                name = "回溯伙伴",
                text = {
                    "跳过{C:attention}盲注{}时",
                    "额外获得{C:attention}#1#{}份标签",
                },
                unlock={
                    "使用{C:attention}回溯",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_vote={
                name = "选票伙伴",
                text = {
                    "重复触发",
                    "{C:attention}第一张{}计分牌",
                },
                unlock={
                    "使用{C:attention}未断选票",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_vote_1={
                name = "选票伙伴",
                text = {
                    "{C:attention}第一张{}计分牌",
                    "额外触发{C:attention}#1#{}次",
                },
                unlock={
                    "使用{C:attention}未断选票",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_bleed={
                name = "血石伙伴",
                text = {
                    "打出的第一张",
                    "{C:hearts}红桃牌{}在计分时",
                    "给予{X:mult,C:white}X#1#{}倍率",
                },
                unlock={
                    "使用{C:attention}血石",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_andrew={
                name = "安迪伙伴",
                text = {
                    "点击支付{C:money}$#1#{}",
                    "弃牌次数{C:red}+#2#{}",
                },
                unlock={
                    "使用{C:attention}快乐安迪",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_andrew_1={
                name = "安迪伙伴",
                text = {
                    "点击支付{C:money}$#1#{}",
                    "抽取{C:attention}#3#{}张牌",
                },
                unlock={
                    "使用{C:attention}快乐安迪",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_thrill={
                name = "特技伙伴",
                text = {
                    "{C:chips}+#1#{}筹码",
                },
                unlock={
                    "使用{C:attention}特技演员",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_napkin={
                name = "头脑伙伴",
                text = {
                    "小丑牌槽位{C:dark_edition}+#1#{}",
                },
                unlock={
                    "使用{C:attention}头脑风暴",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_napkin_1={
                name = "头脑伙伴",
                text = {
                    "小丑牌槽位{C:dark_edition}+#1#{}",
                    "复制最左边的",
                    "{C:attention}小丑牌的能力{}",
                },
                unlock={
                    "使用{C:attention}头脑风暴",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_valid={
                name = "驾照伙伴",
                text = {
                    "令每回合{C:attention}第一张{}",
                    "基础计分牌",
                    "变成随机{C:enhanced}增强牌{}",
                },
                unlock={
                    "使用{C:attention}驾驶执照",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_valid_1={
                name = "驾照伙伴",
                text = {
                    "每次出牌",
                    "令{C:attention}第一张{}基础计分牌",
                    "变成随机{C:enhanced}增强牌{}",
                },
                unlock={
                    "使用{C:attention}驾驶执照",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
            pnr_partner_blaze={
                name = "烧焦伙伴",
                text = {
                    "有{C:green}#1#/#2#{}几率升级",
                    "弃掉的{C:attention}牌型等级{}",
                },
                unlock={
                    "使用{C:attention}烧焦小丑",
                    "在{C:attention}金注",
                    "难度下获胜",
                },
            },
        },
        Other={
            memory_negative={
                name="负片",
                text={
                    "{C:dark_edition}+#1#{}卡牌槽位",
                },
            },
        },
        Mod={
            partner={
                name = "伙伴API",
                text = {
                    "新增{C:red}24{}个以小丑为原型的伙伴",
                    " ",
                    " ",
                    "{C:gold}制作组{}",
                    "Baimao，Betmma，",
                    "Brookling 和 Snowylight",
                    " ",
                    " ",
                    "{C:green}感谢{}",
                    "Clay，Gainumki，",
                    "Larswijn，Spriter",
                    "和 Theonegoofali",
                    " ",
                    " ",
                    "点击浏览{C:blue}wiki{}页面：",
                    "{C:attention}https://balatromods.miraheze.org/wiki/Partner{}",
                }
            }
        },
    },
    misc={
        dictionary={
            b_partners="伙伴",
            b_partner_agree="选择伙伴",
            b_partner_random="随机伙伴",
            b_partner_skip="忽略伙伴",
            b_open_partner_wiki="点击打开伙伴维基",
            k_partner="伙伴",
            k_partner_buffed_level="增益等级",
            k_enable_partner="启用伙伴",
            k_enable_speech_bubble="启用对话气泡",
            k_temporary_unlock_all="临时解锁全部",
            k_partner_destroyed="摧毁！",
            k_partner_enhanced="增强！",
            ml_partner_unique_ability={
                "小丑可能会强化",
                "对应伙伴的能力",
            },
        },
        quips={
            ending_1={
                "向前，成就伟大！",
                "向前，直到黎明！",
            },
            general_1={
                "你好，",
                "我的朋友！",
            },
            general_2={
                "我会一直",
                "和你在一起的！",
            },
            general_3={
                "相信你能有",
                "亮眼的表现！",
            },
            general_4={
                "这局我觉得",
                "你能赢！",
            },
            general_5={
                "专业伙伴",
                "总是有备而来",
            },
            general_6={
                "鸣谢：",
                "Brookling",
                "Snowylight",
                "Betmma",
            },
            low_1={
                "你之前玩的",
                "可比这更好",
            },
            low_2={
                "下一回合",
                "目标要定高点",
            },
            low_3={
                "这将是漫长",
                "而无聊的一局",
            },
            low_4={
                "你没输，暂时的",
            },
            low_5={
                "有点困了",
            },
            low_6={
                "我怎么会在这？",
            },
            medium_1={
                "...还不错",
            },
            medium_2={
                "对于一个笨拙的家伙",
                "来说还行吧",
            },
            medium_3={
                "这一回合",
                "我猜没问题吧",
            },
            medium_4={
                "合理运用你的出牌",
            },
            medium_5={
                "我的评价是C...C-",
            },
            medium_6={
                "貌似我小看你了",
            },
            high_1={
                "我们是最好的搭档！",
            },
            high_2={
                "精彩的演出",
            },
            high_3={
                "最终盲注，我们来了！",
            },
            high_4={
                "太棒了",
            },
            high_5={
                "加油！小丑伙伴们",
            },
            high_6={
                "这是一次很棒的旅程",
            },
            pnr_partner_mute_1={
                ":)"
            },
            pnr_partner_mute_2={
                ":D"
            },
            pnr_partner_mute_3={
                ":P"
            },
            pnr_partner_mute_4={
                ":I"
            },
            pnr_partner_mute_5={
                "XD"
            },
            pnr_partner_mute_6={
                ":l"
            },
            pnr_partner_jump_1={
                "太酷啦！"
            },
            pnr_partner_jump_2={
                "如果你不喜欢",
                "某些盲注",
                "说不然后跳过！"
            },
            pnr_partner_jump_3={
                "明智的选择！"
            },
            pnr_partner_jump_4={
                "冲啊!"
            },
            pnr_partner_jump_5={
                "让我们",
                "一起摇摆！"
            },
            pnr_partner_jump_6={
                "芜湖！", 
                "最机灵的伙伴",
                "来报到啦！"
            },
        },
    },
}
