    <%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="acl" type="java.lang.String"--%>
<template:addResources type="css" resources="forum.css"/>
<template:addResources type="javascript" resources="jquery.min.js,jquery.cuteTime.js"/>
<%-- Get all contents --%>

<jcr:nodeProperty node="${currentNode}" name="jcr:title" var="title"/>
<jcr:nodeProperty node="${currentNode}" name="content" var="content"/>
<jcr:nodeProperty node="${currentNode}" name="pseudo" var="createdBy"/>
<jcr:nodeProperty node="${currentNode}" name="jcr:created" var="created"/>
<c:choose>
    <c:when test="${empty createdBy}">
        <jcr:nodeProperty node="${currentNode}" name="jcr:createdBy" var="createdBy"/>
        <jcr:node var="userNode" path="${functions:lookupUser(createdBy.string).localPath}"/>
        <jcr:sql var="numberOfPostsQuery"
                 sql="select [jcr:uuid] from [jnt:post] as p where p.[jcr:createdBy] = '${createdBy.string}'"/>
    </c:when>
    <c:otherwise>
        <jcr:sql var="numberOfPostsQuery"
                 sql="select [jcr:uuid] from [jnt:post] as p where p.[pseudo] = '${createdBy.string}'"/>
    </c:otherwise>
</c:choose>


<c:if test="${jcr:hasPermission(currentNode, 'deletePost')}">
    <template:tokenizedForm>
        <form action="<c:url value='${url.base}${currentNode.path}'/>" method="post"
              id="jahia-forum-post-delete-${currentNode.UUID}">
            <input type="hidden" name="jcrRedirectTo" value="<c:url value='${url.base}${renderContext.mainResource.node.path}'/>"/>
                <%-- Define the output format for the newly created node by default html or by redirectTo--%>
            <input type="hidden" name="jcrNewNodeOutputFormat" value="html"/>
            <input type="hidden" name="jcrMethodToCall" value="delete"/>
        </form>
    </template:tokenizedForm>
</c:if>

<c:if test="${jcr:hasPermission(currentNode.parent.parent, 'moderatePost') and jcr:isNodeType(currentNode, 'jmix:moderated')}">
    <template:tokenizedForm>
        <form action="<c:url value='${url.base}${currentNode.path}'/>" method="post"
              id="jahia-forum-post-moderate-${currentNode.UUID}">
            <input type="hidden" name="jcrRedirectTo" value="<c:url value='${url.base}${renderContext.mainResource.node.path}'/>"/>
                <%-- Define the output format for the newly created node by default html or by redirectTo--%>
            <input type="hidden" name="jcrNewNodeOutputFormat" value="html"/>
            <input type="hidden" name="jcrMethodToCall" value="put"/>
            <input type="hidden" name="moderated" value="true"/>
        </form>
    </template:tokenizedForm>
</c:if>

<template:option node="${currentNode}" view="hidden.plusone_minorone_form" nodetype="jmix:rating"/>
<div class="forum-postbody">
	<div class="arrow-left"></div>
    <ul class="forum-profile-icons">
        <%--<c:if test="${jcr:hasPermission(currentNode, 'reportPost')}">--%>
        <%--<li class="forum-report-icon"><a title="<fmt:message key='report.post'/>" href="#"><span><fmt:message key='report.post'/></span></a></li>--%>
        <%--</c:if>--%>
        <c:if test="${jcr:hasPermission(currentNode, 'createPost')}">
            <li class="forum-quote-icon">
                <a title="<fmt:message key='reply'/>"
                href="<c:url value='${url.base}${renderContext.mainResource.node.path}.forum-topic-newPost.html?reply=${currentNode.UUID}'/>">
                    <span>
                        <fmt:message key='reply'/>
                    </span>
                </a>
            </li>
        </c:if>

        <c:if test="${jcr:hasPermission(currentNode, 'createPost')}">
            <li class="forum-quote-icon">
                <a title="<fmt:message key='reply.quote'/>"
                href="<c:url value='${url.base}${renderContext.mainResource.node.path}.forum-topic-newPost.html?reply=${currentNode.UUID}&quote=true'/>">
                    <span>
                        <fmt:message key='reply.quote'/>
                    </span>
                </a>
            </li>
        </c:if>

        <c:if test="${jcr:hasPermission(currentNode, 'deletePost')}">
            <li class="delete-post-icon">
                <fmt:message key="confirm.delete.post" var="confirmMsg"/>
                <a title="<fmt:message key='delete.post'/>" href="#delete"
                                onclick='if (window.confirm("${functions:escapeJavaScript(confirmMsg)}"))
                                        { document.getElementById("jahia-forum-post-delete-${currentNode.UUID}").submit(); } return false;'>
                    <span><fmt:message key='delete.post'/></span>
                </a>
            </li>
        </c:if>
        <c:if test="${jcr:hasPermission(currentNode.parent.parent, 'moderatePost') and jcr:isNodeType(currentNode, 'jmix:moderated') and not currentNode.properties.moderated.boolean}">
            <li class="delete-post-icon"><a title="<fmt:message key='moderate.post'/>" href="#moderate"
                                            onclick="document.getElementById('jahia-forum-post-moderate-${currentNode.UUID}').submit(); return false;"><span>
        <fmt:message key="moderate.post"/>
        </span></a></li>
        </c:if>
        <c:if test="${jcr:hasPermission(currentNode, 'editPost')}">
            <li class="edit-post-icon"><a title="<fmt:message key='edit.post'/>" href="#edit"
                                          onclick="$('#edit${currentNode.UUID}').dblclick(); return false;"><span><fmt:message
                    key="edit.post"/></span></a></li>
        </c:if>
    </ul>


<template:option node="${currentNode}" view="hidden.plusone_minorone" nodetype="jmix:rating"/>

    <h4 class="forum-h4-first"><c:out value="${title.string}" /></h4>

    <p class="forum-author">
        <c:if test="${currentNode.properties['jcr:createdBy'].string ne 'guest'}">
            <fmt:message key="by"/>
            <strong>&nbsp;<a
                    href="<c:url value='${url.base}${functions:lookupUser(createdBy.string).localPath}.forum-profile.html?jsite=${currentNode.resolveSite.identifier}'/>">${createdBy.string}</a></strong>&nbsp;&raquo;&nbsp;<span class="timestamp">
            <fmt:formatDate
                    value="${created.time}" pattern="yyyy/MM/dd HH:mm"/>
            </span> </c:if>
        <c:if test="${currentNode.properties['jcr:createdBy'].string eq 'guest'}">
            <fmt:message key="by"/>
            <strong>&nbsp;${createdBy.string}</strong>&nbsp;&raquo;&nbsp;<span class="timestamp">
            <fmt:formatDate
                    value="${created.time}" pattern="yyyy/MM/dd HH:mm"/>
            </span> </c:if>
    </p>
    <c:if test="${jcr:hasPermission(currentNode, 'editPost')}">
        <div class="content editablePost" jcr:id="content"
             id="edit${currentNode.identifier}"
             jcr:url="<c:url value='${url.base}${currentNode.path}'/>">${content.string}</div>
    </c:if>
    <c:if test="${not jcr:hasPermission(currentNode, 'editPost')}">
        <div class="content">${content.string}</div>
    </c:if>
</div>

<c:set var="numberOfPosts" value="${functions:length(numberOfPostsQuery.rows)}"/>
<c:choose>
    <c:when test="${not empty userNode}">
        <dl class="forum-postprofile">
            <dt>
                <template:module node="${userNode}" view="mini"/>
            </dt>
            <dd><strong>
                <fmt:message key="number.of.posts"/>
            </strong>&nbsp;${numberOfPosts}</dd>
            <dd><strong>
                <fmt:message key="registration.date"/>
            </strong>
                <jcr:nodeProperty node="${userNode}" name="jcr:lastModified"
                                  var="userCreated"/>
                <fmt:formatDate value="${userCreated.time}" type="date" dateStyle="medium"/>
            </dd>
        </dl>
    </c:when>
    <c:otherwise>
        <dl class="forum-postprofile">
            <dt>
                ${createdBy.string}
            </dt>
            <dd><strong>
                <fmt:message key="number.of.posts"/>
            </strong>&nbsp;${numberOfPosts}</dd>
            <dd><strong>
                <fmt:message key="not.registered"/>
            </strong>
            </dd>
        </dl>
    </c:otherwise>
</c:choose>
<div id="back2top${currentNode.identifier}" class="back2top"></div>
<script type="text/javascript">
    var allTags = document.body.getElementsByTagName('*');
    for (var tg = 0; tg < allTags.length; tg++) {
        var tag = allTags[tg];
        if (tag.id || $('#back2top${currentNode.identifier}').size() == 0) {
            $('#back2top${currentNode.identifier}').append($('<a>Top</a>').attr('title','Top').attr('class','top').attr('href','#'+tag.id));
            break;
        }
    }
</script>
<div class="clear"></div>
