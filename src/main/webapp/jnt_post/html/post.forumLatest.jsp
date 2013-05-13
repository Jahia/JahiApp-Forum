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



<c:if test="${jcr:hasPermission(currentNode, 'deletePost')}">
    <template:tokenizedForm>
        <form action="<c:url value='${url.base}${currentNode.path}'/>" method="post"
              id="jahia-forum-post-delete-${currentNode.UUID}">
            <input type="hidden" name="jcrRedirectTo" value="<c:url value='${url.base}${renderContext.mainResource.node.path}.forum-profile.html?jsite=${currentNode.resolveSite.identifier}'/>"/>
                <%-- Define the output format for the newly created node by default html or by redirectTo--%>
            <input type="hidden" name="jcrNewNodeOutputFormat" value=""/>
            <input type="hidden" name="jcrMethodToCall" value="delete"/>
        </form>
    </template:tokenizedForm>
</c:if>

<c:if test="${jcr:hasPermission(currentNode.parent.parent, 'moderatePost') and jcr:isNodeType(currentNode, 'jmix:moderated')}">
    <template:tokenizedForm>
        <form action="<c:url value='${url.base}${currentNode.path}'/>" method="post"
              id="jahia-forum-post-moderate-${currentNode.UUID}">
            <input type="hidden" name="jcrRedirectTo" value="<c:url value='${url.base}${renderContext.mainResource.node.path}.forum-profile.html?jsite=${currentNode.resolveSite.identifier}'/>"/>
                <%-- Define the output format for the newly created node by default html or by redirectTo--%>
            <input type="hidden" name="jcrNewNodeOutputFormat" value=""/>
            <input type="hidden" name="jcrMethodToCall" value="put"/>
            <input type="hidden" name="moderated" value="true"/>
        </form>
    </template:tokenizedForm>
</c:if>

<template:option node="${currentNode}" view="hidden.plusone_minorone_form" nodetype="jmix:rating"/>
<div class="forum-postbody">
	<div class="arrow-left"></div>
    <ul class="forum-profile-icons">
            <li class="forum-quote-icon">
                <a title="<fmt:message key='view.thread'/>"
                href="<c:url value='${url.base}${currentNode.parent.path}.html'/>">
                    <span>
                        <fmt:message key='view.thread'/>
                    </span>
                </a>
            </li>
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
         <%-- <c:if test="${jcr:hasPermission(currentNode, 'editPost')}">
            <li class="edit-post-icon"><a title="<fmt:message key='edit.post'/>" href="#edit"
                                          onclick="$('#edit${currentNode.UUID}').dblclick(); return false;"><span><fmt:message
                    key="edit.post"/></span></a></li>
        </c:if>--%>
    </ul>

    <h4 class="forum-h4-first"><c:out value="${title.string}" /></h4>

    <c:if test="${jcr:hasPermission(currentNode, 'editPost')}">
        <div class="content editablePost" jcr:id="content"
             id="edit${currentNode.identifier}"
             jcr:url="<c:url value='${url.base}${currentNode.path}'/>">${content.string}</div>
    </c:if>
    <c:if test="${not jcr:hasPermission(currentNode, 'editPost')}">
        <div class="content">${content.string}</div>
    </c:if>
</div>
<div class="user-posts">
        <p class="forum-date">
        <span class="timestamp">
            <fmt:formatDate
                    value="${created.time}" pattern="yyyy/MM/dd HH:mm"/>
        </span>
        </p>
</div>
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
