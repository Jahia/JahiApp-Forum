<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<template:include view="hidden.header"/>
<c:set var="linked" value="${uiComponents:getBindedComponent(currentNode, renderContext, 'j:bindedComponent')}"/>
<c:if test="${not empty linked}">
    <c:set value="${jcr:getParentOfType(renderContext.mainResource.node, 'jmix:moderated')}" var="moderated"/>
    <c:choose>
        <c:when test="${empty moderated or jcr:hasPermission(moderated, 'moderatePost')}">
            <jcr:sql var="numberOfPostsQuery"
                     sql="select [jcr:uuid] from [jnt:post] as p  where isdescendantnode(p,['${linked.path}'])"/>
            <jcr:sql var="numberOfThreadsQuery"
                     sql="select [jcr:uuid] from [jnt:topic] as t  where isdescendantnode(t,['${linked.path}'])"/>
        </c:when>
        <c:otherwise>
            <jcr:sql var="numberOfPostsQuery"
                     sql="select [jcr:uuid] from [jnt:post] as p  where isdescendantnode(p,['${linked.path}']) and p.['moderated']=true"/>
            <jcr:sql var="numberOfThreadsQuery"
                     sql="select [jcr:uuid] from [jnt:topic] as t  where isdescendantnode(t,['${linked.path}']) and t.['moderated']=true"/>
        </c:otherwise>
    </c:choose>
    <c:set var="numberOfPosts" value="${numberOfPostsQuery.rows.size}"/>
    <c:set var="numberOfThreads" value="${numberOfThreadsQuery.rows.size}"/>
    <template:addResources type="css" resources="forum.css"/>
    <template:addCacheDependency node="${linked}"/>
    <div class="topics">
        <jcr:nodeProperty node="${linked}" name="jcr:title" var="topicSubject"/>
            <%--<c:if test="${!empty topicSubject.string}">--%>
            <%--<h2><a href="<c:url value='${url.base}${linked.parent.path}.forum-topic.html'/>">${topicSubject.string}</a></h2>--%>
            <%--</c:if>--%>
        <div class="forum-box forum-box-style1 topics">

            <ul class="forum-list">
                <li class="forum-list-header">
                    <dl class="icon">
                        <dt><fmt:message key="topic"/></dt>
                        <dd class="topics"><fmt:message key="posts"/></dd>
                        <dd class="posts"><fmt:message key="views"/></dd>
                        <dd class="lastpost"><span><fmt:message key="lastPosts"/></span></dd>
                    </dl>
                </li>
            </ul>

            <ul class="forum-list forums">
                <c:forEach items="${moduleMap.currentList}" var="subchild" varStatus="status" begin="${moduleMap.begin}" end="${moduleMap.end}">
                    <c:if test="${jcr:isNodeType(subchild, 'jnt:topic')}">
                        <template:addCacheDependency node="${subchild}"/>
                        <li class="row">
                            <template:module node="${subchild}" view="${moduleMap.subNodesView}"/>
                        </li>
                        <c:set var="found" value="true"/>
                    </c:if>
                </c:forEach>

                <c:if test="${not found}">
                    <li class="row">
                        <p><fmt:message key="no.topic.found"/></p>
                    </li>
                </c:if>

            </ul>
            <div class="clear"></div>
        </div>
        <span><fmt:message key="total.threads"/>:&nbsp;${numberOfThreads}</span>
        <span><fmt:message key="total.posts"/>:&nbsp;${numberOfPosts}</span>
    </div>

</c:if>
