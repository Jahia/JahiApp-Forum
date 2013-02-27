<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>

<c:set value="${jcr:getParentOfType(currentNode, 'jmix:moderated')}" var="moderated"/>
<c:choose>
    <c:when test="${not jcr:hasPermission(currentNode, 'moderatePost') and not empty moderated}">
        <jcr:sql var="numberOfPostsQuery"
                 sql="select * from [jnt:post] as post  where isdescendantnode(post, ['${currentNode.path}']) and post.[moderated]='true' and (post.['jcr:mixinTypes'] not like 'jmix:spamFilteringSpamDetected') order by post.[jcr:lastModified] desc"/>
    </c:when>
    <c:otherwise>
        <jcr:sql var="numberOfPostsQuery"
                 sql="select * from [jnt:post] as post  where isdescendantnode(post, ['${currentNode.path}']) and (post.['jcr:mixinTypes'] not like 'jmix:spamFilteringSpamDetected') order by post.[jcr:lastModified] desc"/>
    </c:otherwise>
</c:choose>

<c:set var="numberOfPosts" value="${numberOfPostsQuery.nodes.size}"/>
<c:forEach items="${numberOfPostsQuery.nodes}" var="node" varStatus="status" end="2">
    <c:if test="${status.first}">
        <c:set value="${node}" var="lastModifiedNode"/>
        <jcr:nodeProperty node="${node}" name="jcr:lastModified" var="lastModified"/>
        <jcr:nodeProperty node="${lastModifiedNode}" name="jcr:createdBy" var="createdBy"/>
    </c:if>
</c:forEach>
<c:if test="${jcr:hasPermission(currentNode, 'deleteTopic')}">
    <template:tokenizedForm>
        <form action="<c:url value='${url.base}${currentNode.path}'/>" method="post"
              id="jahia-forum-topic-delete-${currentNode.UUID}">
            <input type="hidden" name="jcrRedirectTo"
                   value="<c:url value='${url.base}${renderContext.mainResource.node.path}'/>"/>
                <%-- Define the output format for the newly created node by default html or by redirectTo--%>
            <input type="hidden" name="jcrNewNodeOutputFormat" value="html"/>
            <input type="hidden" name="jcrMethodToCall" value="delete"/>
        </form>
    </template:tokenizedForm>
</c:if>
<%--<c:if test="${numberOfPosts > 0 or jcr:hasPermission(currentNode, 'deleteTopic')}">--%>
    <%--<li class="row">--%>
    <dl class="icon icontopic">
    <dt title="posts">
        <c:if test="${jcr:hasPermission(currentNode, 'deleteTopic')}"><ul class="forum-profile-icons">
            <li class="delete-post-icon">
                <fmt:message key="confirm.delete.topic" var="confirmMsg"/>
                <a title="<fmt:message key='delete.topic'/>" href="#"
                                onclick='if (window.confirm("${functions:escapeJavaScript(confirmMsg)}"))
                                        { document.getElementById("jahia-forum-topic-delete-${currentNode.UUID}").submit(); } return false;'>
                    <span><fmt:message key='delete.topic'/></span>
                </a>
            </li>

    </ul></c:if>
    <c:if test="${numberOfPosts > 0}">
        <a class="forum-title"
           href="<c:url value='${url.base}${currentNode.path}.html'/>"><c:out value="${currentNode.properties.topicSubject.string}" /></a>
    </c:if>
    <c:if test="${numberOfPosts == 0}">
        <c:out value="${currentNode.properties.topicSubject.string}" />
    </c:if>
        <br/>
    <p>
        <fmt:message key="mix_created.jcr_createdBy"/>&nbsp;${currentNode.properties["jcr:createdBy"].string}&nbsp;<fmt:formatDate value="${currentNode.properties['jcr:created'].time}" dateStyle="full" type="both"/>
    </p>

    </dt>
        <%--<dd class="topics">30</dd>--%>
    <dd class="posts">${numberOfPosts}</dd>
    <dd class="posts">${currentNode.properties["nbOfViews"].string}</dd>
        <dd class="lastpost">
            <c:if test="${numberOfPosts > 0}">
                <span>
                    <dfn><fmt:message key="last.post"/></dfn> <fmt:message key="by"/>
                    <c:if test="${createdBy.string eq 'guest'}">
                        ${createdBy.string} <br/><fmt:formatDate value="${lastModified.time}" dateStyle="full" type="both"/>
                    </c:if>
                    <c:if test="${createdBy.string ne 'guest'}">
                        <a href="<c:url value='${url.base}${functions:lookupUser(createdBy.string).localPath}.forum-profile.html?jsite=${currentNode.resolveSite.identifier}'/>"><img height="9"
                                                                                                                                                                                      width="11"
                                                                                                                                                                                      title="View the latest post"
                                                                                                                                                                                      alt="View the latest post"
                                                                                                                                                                                      src="<c:url value='${url.currentModule}/css/img/icon_topic_latest.gif'/>"/>${createdBy.string}
                        </a><br/><fmt:formatDate value="${lastModified.time}" dateStyle="full" type="both"/>
                    </c:if>
                </span>
            </c:if>
        </dd>
    </dl>
<%--</li>--%>
<%--</c:if>--%>
<%--<c:if test="${numberOfPosts == 0}">--%>
    <%--<template:addCacheDependency flushOnPathMatchingRegexp="\Q${currentNode.path}\E/.*"/>--%>
<%--</c:if>--%>
