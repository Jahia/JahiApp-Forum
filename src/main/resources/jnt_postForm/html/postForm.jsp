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
<template:addResources type="css" resources="forum.css"/>
<template:addResources type="javascript" resources="jquery.min.js,jquery.validate.js"/>
<template:addResources type="inlinejavascript">
    <script type="text/javascript">
        $(document).ready(function() {
            $("#newTopicForm").validate({
                rules: {
                    'jcr:title': "required",
                    <c:if test="${not renderContext.loggedIn}">
                    pseudo: "required"
                    </c:if>
                }
            });
        });
    </script>
</template:addResources>
<uiComponents:ckeditor selector="jahia-forum-thread-${currentNode.UUID}"/>

<c:set var="linked" value="${uiComponents:getBindedComponentPath(currentNode, renderContext, 'j:bindedComponent')}"/>

<a name="threadPost"></a>
<c:if test="${!empty param.reply}">
    <jcr:node uuid="${param.reply}" var="reply"/>
    <template:addCacheDependency node="${reply}"/>
</c:if>
<jcr:node var="linkedNode" path="${linked}"/>
<c:if test="${not empty linkedNode}">
    <c:choose>
        <c:when test="${jcr:isNodeType(linkedNode,'jnt:topic')}">
            <c:set value="${jcr:getParentOfType(linkedNode.parent, 'jmix:moderated')}" var="moderated"/>
        </c:when>
        <c:otherwise>
            <c:set value="${jcr:getParentOfType(linkedNode, 'jmix:moderated')}" var="moderated"/>
        </c:otherwise>
    </c:choose>
</c:if>
<template:tokenizedForm>
    <form action="<c:url value='${url.base}${linked}.addTopic.do'/>" method="post" name="newTopicForm" id="newTopicForm">
        <input type="hidden" name="jcrNodeType" value="jnt:post"/>
        <input type="hidden" name="jcrRedirectTo"
               value="<c:url value='${url.base}${renderContext.mainResource.node.path}.${renderContext.mainResource.template}'/>"/>
        <input type="hidden" name="jcrNewNodeOutputFormat" value="html"/>
        <input type="hidden" name="jcrResourceID" value="${currentNode.identifier}"/>
        <input type="hidden" name="jcr:mixinTypes" value="jmix:rating"/>
        <c:if test="${not empty moderated}">
            <input type="hidden" name="jcr:mixinTypes" value="jmix:moderated"/>
        </c:if>
        <div class="post-reply">
            <!--start post-reply-->
            <div class="forum-Form">
                <!--start forum-Form-->
                <h4 class="forum-h4-first">${fn:escapeXml(currentNode.displayableName)}:</h4>
                <c:if test="${not empty moderated}">
                    <p>
                        <span><fmt:message key="moderated.post"/></span>
                    </p>
                </c:if>
                <fieldset>
                    <p class="field">
                        <c:if test="${not renderContext.loggedIn}">
                            <label for="newTopic_pseudo"><fmt:message key="comment.pseudo"/></label>
                            <c:if test="${not empty sessionScope.formDatas['pseudo']}"><input
                                    value="${sessionScope.formDatas['pseudo'][0]}"
                                    type="text" size="35" name="pseudo" id="newTopic_pseudo"
                                    tabindex="1"/></c:if>
                            <c:if test="${empty sessionScope.formDatas['pseudo']}">
                                <input value=""
                                       type="text" size="35" name="pseudo" id="newTopic_pseudo"
                                       tabindex="1"/></c:if>
                        </c:if>
                        </p>
                        <p class="field">
                        <fmt:message key="reply.prefix" var="replyPrefix"/><c:set var="replyPrefix"
                                                                                  value="${replyPrefix} "/>
                        <c:set var="replyTitle" value="${reply.properties['jcr:title'].string}"/>
						<label for="newTopic_title"><fmt:message key="label.title"/></label>
                        <c:if test="${not empty sessionScope.formDatas['jcr:title']}"><input
                                value="${sessionScope.formDatas['jcr:title'][0]}"
                                type="text" size="35" id="newTopic_title" name="jcr:title"
                                tabindex="1"/></c:if>
                        </p>
                        <p class="field">     
                        <c:if test="${empty sessionScope.formDatas['jcr:title']}">
                            <input value="${not empty replyTitle ? replyPrefix : ''}${not empty replyTitle ? fn:escapeXml(replyTitle) : ''}"
                                   type="text" size="35" id="newTopic_title" name="jcr:title"
                                   tabindex="1"/></c:if>
						</p>
                    <p class="field"><label for="jahia-forum-thread-${currentNode.UUID}"><fmt:message
                key="label.description"/></label>
                        <textarea rows="7" cols="35" id="jahia-forum-thread-${currentNode.UUID}" name="content"
                                  tabindex="2" class="jahia-ckeditor">
                            <c:if test="${not empty sessionScope.formDatas['content']}">
                                ${fn:escapeXml(sessionScope.formDatas['content'][0])}
                            </c:if>
                            <c:if test="${(not empty reply.properties['content'].string) && (not empty param.quote)}">
                            <blockquote><c:out value="${reply.properties['content'].string}" /></blockquote><br />
                            <p>
                            </p>
                        </c:if></textarea>
                    </p>
                    <script>
                        initValue =  document.getElementById("jahia-forum-thread-${currentNode.UUID}").value
                    </script>
                    <p class="forum_button">
                        <input type="reset" value="<fmt:message key='label.reset'/>" class="button" tabindex="3" onclick="CKEDITOR.instances['jahia-forum-thread-${currentNode.UUID}'].setData(initValue);"/>
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
