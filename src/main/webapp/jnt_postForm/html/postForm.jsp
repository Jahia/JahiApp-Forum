<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<template:linker property="j:bindedComponent"/>
<template:addResources type="css" resources="forum.css"/>
<c:set var="linked" value="${uiComponents:getBindedComponentPath(currentNode, renderContext, 'j:bindedComponent')}"/>
<template:addResources type="css" resources="forum.css"/>
<script type="text/javascript">
    function jahiaForumQuote(targetId, quotedText) {
        var targetArea = document.getElementById(targetId);
        if (targetArea) {
            targetArea.value = targetArea.value + '\n<blockquote>\n' + quotedText + '\n</blockquote>\n';
        }
        return false;
    }
</script>

<a name="threadPost"></a>
<c:if test="${!empty param.reply}">
  <jcr:node uuid="${param.reply}" var="reply"/>
</c:if>
<template:tokenizedForm>
  <form action="${url.base}${linked}.addTopic.do" method="post" name="newTopicForm">
    <div class="post-reply">
      <!--start post-reply-->
      <div class="forum-Form">
        <!--start forum-Form-->
        <h4 class="forum-h4-first">${fn:escapeXml(currentNode.displayableName)}:</h4>
        <fieldset>
          <p class="field">
          	<fmt:message key="reply.prefix" var="replyPrefix"/><c:set var="replyPrefix" value="${replyPrefix} "/>
          	<c:set var="replyTitle" value="${reply.properties['jcr:title'].string}"/>
            <input value="${not empty replyTitle ? replyPrefix : ''}${not empty replyTitle ? fn:escapeXml(replyTitle) : ''}"
            type="text" size="35" id="forum_site" name="jcr:title"
            tabindex="1"/> </p>
          <p class="field">
            <textarea rows="7" cols="35" id="jahia-forum-thread-${currentNode.UUID}" name="content"
                                      tabindex="2"><c:if test="${not empty reply.properties['content'].string}"><blockquote>${reply.properties['content'].string}</blockquote></c:if></textarea>
          </p>
          <p class="forum_button">
            <input type="reset" value="<fmt:message key='label.reset'/>" class="button" tabindex="3"/>
            <input type="submit" value="<fmt:message key='label.submit'/>" class="button" tabindex="4"/>
          </p>
        </fieldset>
      </div>
      <!--stop forum-Form-->
      <div class="clear"></div>
    </div>
    <!--stop post-reply-->
  </form>
</template:tokenizedForm>
