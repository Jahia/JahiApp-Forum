<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<template:addResources type="css" resources="forum.css"/>
<jcr:jqom var="topics">
    <query:selector nodeTypeName="jnt:topic"/>
    <query:descendantNode path="/"/>
</jcr:jqom>
<c:if test="${topics.nodes.size == 0}">
    No Topics Found
</c:if>

<ul>
<c:forEach items="${topics.nodes}" var="topic">
    <li><a href="${url.base}${topic.path}.html"><jcr:nodeProperty node="${topic}" name="topicSubject"/> (${functions:length(topic.nodes)} threads)</a></li>
</c:forEach>
</ul>
