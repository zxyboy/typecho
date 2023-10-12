-- phpMyAdmin SQL Dump
-- version 2.11.5
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2008 年 07 月 06 日 18:00
-- 服务器版本: 5.0.51
-- PHP 版本: 5.2.5

--
-- 数据库: `typecho`
--

-- --------------------------------------------------------

--
-- 表的结构 `typecho_comments`
--

CREATE TABLE `typecho_comments`
(
    `coid`     int(10) unsigned NOT NULL auto_increment COMMENT '评论ID',
    `cid`      int(10) unsigned default '0' COMMENT '文章ID',
    `created`  int(10) unsigned default '0' COMMENT '评论时间',
    `author`   varchar(150) default NULL COMMENT '评论者昵称',
    `authorId` int (10) unsigned default '0' COMMENT '评论者ID',
    `ownerId`  int(10) unsigned default '0' COMMENT '文章所有者ID',
    `mail`     varchar(150) default NULL COMMENT '评论者邮箱',
    `url`      varchar(255) default NULL COMMENT '评论者网址',
    `ip`       varchar(64)  default NULL COMMENT '评论者IP',
    `agent`    varchar(511) default NULL COMMENT '评论者客户端',
    `text`     text COMMENT '评论内容',
    `type`     varchar(16)  default 'comment' COMMENT '评论类型',
    `status`   varchar(16)  default 'approved' COMMENT '评论状态',
    `parent`   int(10) unsigned default '0' COMMENT '父级评论ID',
    PRIMARY KEY (`coid`),
    KEY        `cid` (`cid`),
    KEY        `created` (`created`)
) ENGINE=%engine%  DEFAULT CHARSET=%charset% COMMENT='博客评论表';

-- --------------------------------------------------------

--
-- 表的结构 `typecho_contents`
--

CREATE TABLE `typecho_contents`
(
    `cid`          int(10) unsigned NOT NULL auto_increment COMMENT '文章ID',
    `title`        varchar(150) default NULL COMMENT '文章标题',
    `slug`         varchar(150) default NULL COMMENT '文章缩略名',
    `created`      int(10) unsigned default '0' COMMENT '文章创建时间',
    `modified`     int(10) unsigned default '0' COMMENT '文章修改时间',
    `text`         longtext COMMENT '文章内容',
    `order`        int(10) unsigned default '0' COMMENT '文章顺序',
    `authorId`     int(10) unsigned default '0' COMMENT '文章作者ID',
    `template`     varchar(32)  default NULL COMMENT '文章模板',
    `type`         varchar(16)  default 'post' COMMENT '文章类型',
    `status`       varchar(16)  default 'publish' COMMENT '文章状态',
    `password`     varchar(32)  default NULL COMMENT '文章密码',
    `commentsNum`  int(10) unsigned default '0' COMMENT '文章评论数',
    `allowComment` char(1)      default '0' COMMENT '是否允许评论',
    `allowPing`    char(1)      default '0' COMMENT '是否允许被引用',
    `allowFeed`    char(1)      default '0' COMMENT '是否允许在Feed中出现',
    `parent`       int(10) unsigned default '0' COMMENT '父级文章ID',
    PRIMARY KEY (`cid`),
    UNIQUE KEY `slug` (`slug`),
    KEY            `created` (`created`)
) ENGINE=%engine%  DEFAULT CHARSET=%charset% COMMENT='博客文章表';

-- --------------------------------------------------------

--
-- 表的结构 `typecho_fields`
--

CREATE TABLE `typecho_fields`
(
    `cid`         int(10) unsigned NOT NULL COMMENT '文章ID',
    `name`        varchar(150) NOT NULL COMMENT '字段名称',
    `type`        varchar(8) default 'str' COMMENT '字段类型',
    `str_value`   text COMMENT '字符串值',
    `int_value`   int(10) default '0' COMMENT '整数值',
    `float_value` float      default '0' COMMENT '浮点值',
    PRIMARY KEY (`cid`, `name`),
    KEY           `int_value` (`int_value`),
    KEY           `float_value` (`float_value`)
) ENGINE=%engine%  DEFAULT CHARSET=%charset% COMMENT='博客文章自定义字段表';

-- --------------------------------------------------------

--
-- 表的结构 `typecho_metas`
--

CREATE TABLE `typecho_metas`
(
    `mid`         int(10) unsigned NOT NULL auto_increment COMMENT '分类、标签ID',
    `name`        varchar(150)         default NULL COMMENT '分类、标签名称',
    `slug`        varchar(150)         default NULL COMMENT '分类、标签缩略名',
    `type`        varchar(32) NOT NULL default 'category' COMMENT '分类、标签类型',
    `description` varchar(150)         default NULL COMMENT '分类、标签描述',
    `count`       int(10) unsigned default '0' COMMENT '分类、标签下的文章数',
    `order`       int(10) unsigned default '0' COMMENT '分类、标签顺序',
    `parent`      int(10) unsigned default '0' COMMENT '父级分类ID',
    PRIMARY KEY (`mid`),
    KEY           `slug` (`slug`)
) ENGINE=%engine%  DEFAULT CHARSET=%charset% COMMENT='博客分类、标签表';

-- --------------------------------------------------------

--
-- 表的结构 `typecho_options`
--

CREATE TABLE `typecho_options`
(
    `name`  varchar(32) NOT NULL default '' COMMENT '配置名称',
    `user`  int(10) unsigned NOT NULL default '0' COMMENT '用户ID',
    `value` text COMMENT '配置值',
    PRIMARY KEY (`name`, `user`)
) ENGINE=%engine% DEFAULT CHARSET=%charset% COMMENT='博客配置表';

-- --------------------------------------------------------

--
-- 表的结构 `typecho_relationships`
--

CREATE TABLE `typecho_relationships`
(
    `cid` int(10) unsigned NOT NULL COMMENT '文章ID',
    `mid` int(10) unsigned NOT NULL COMMENT '分类、标签ID',
    PRIMARY KEY (`cid`, `mid`)
) ENGINE=%engine% DEFAULT CHARSET=%charset% COMMENT='博客文章与分类、标签关系表';

-- --------------------------------------------------------

--
-- 表的结构 `typecho_users`
--

CREATE TABLE `typecho_users`
(
    `uid`        int(10) unsigned NOT NULL auto_increment COMMENT '用户ID',
    `name`       varchar(32)  default NULL COMMENT '用户名',
    `password`   varchar(64)  default NULL COMMENT '用户密码',
    `mail`       varchar(150) default NULL COMMENT '用户邮箱',
    `url`        varchar(150) default NULL COMMENT '用户网址',
    `screenName` varchar(32)  default NULL COMMENT '用户昵称',
    `created`    int(10) unsigned default '0' COMMENT '用户创建时间',
    `activated`  int(10) unsigned default '0' COMMENT '用户激活时间',
    `logged`     int(10) unsigned default '0' COMMENT '用户登录时间',
    `group`      varchar(16)  default 'visitor' COMMENT '用户组',
    `authCode`   varchar(64)  default NULL COMMENT '用户认证码',
    PRIMARY KEY (`uid`),
    UNIQUE KEY `name` (`name`),
    UNIQUE KEY `mail` (`mail`)
) ENGINE=%engine%  DEFAULT CHARSET=%charset% COMMENT='博客用户表';
