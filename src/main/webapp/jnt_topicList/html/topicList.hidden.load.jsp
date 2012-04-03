<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<template:addResources type="css" resources="forum.css"/>
<template:addResources type="javascript" resources="jquery.min.js,jquery.cuteTime.js,jquery.jeditable.mini.js"/>

<c:set var="linked" value="${uiComponents:getBindedComponent(currentNode, renderContext, 'j:bindedComponent')}"/>

<c:if test="${not empty linked}">

    <%--<c:set var="topicsStatement" value="SELECT DISTINCT topic.* FROM [jnt:topic] as topic inner join  [jnt:post] as post on ISCHILDNODE(post,topic) where ISCHILDNODE(topic,'${linked.path}') order by topic.['jcr:lastModified'] desc"/>--%>
    <c:set value="${jcr:getParentOfType(renderContext.mainResource.node, 'jmix:moderated')}" var="moderated"/>
    <c:choose>
        <c:when test="${empty moderated or jcr:hasPermission(moderated, 'moderatePost')}">
            <c:set var="topicsStatement" value="select * from [jnt:topic] as topic where ISCHILDNODE(topic,'${linked.path}') order by topic.['topicLastContributionDate'] desc"/>
        </c:when>
        <c:otherwise>
           <c:set var="topicsStatement" value="select * from [jnt:topic] as topic where ISCHILDNODE(topic,'${linked.path}') and topic.['moderated']=true order by topic.['topicLastContributionDate'] desc"/>
        </c:otherwise>
    </c:choose>
    <query:definition var="listQuery" statement="${topicsStatement}" limit="${limit.long}"  />

    <c:set target="${moduleMap}" property="emptyListMessage" value="No topic found" />
    <c:set target="${moduleMap}" property="listQuery" value="${listQuery}" />
    <c:set target="${moduleMap}" property="subNodesView" value="${currentNode.properties['j:subNodesView'].string}" />
    <template:addCacheDependency flushOnPathMatchingRegexp="\Q${linked.path}\E/[^/]*"/>
</c:if>