<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="acl" type="java.lang.String"--%>

<template:addResources type="javascript" resources="jquery.min.js"/>
<template:addResources type="javascript" resources="jquery.cookie.js"/>
<template:addResources type="javascript" resources="jquery.form.js"/>
<c:set var="bindedComponent"
       value="${uiComponents:getBindedComponent(currentNode, renderContext, 'j:bindedComponent')}"/>
<c:if test="${not empty bindedComponent}">

<template:tokenizedForm>
<form action="<c:url value='${url.base}${bindedComponent.path}.IncrementView.do'/>" method="post" id="jahia-viewcount-${currentNode.UUID}">
</form>
</template:tokenizedForm>

<template:addResources>
    <script type="text/javascript">
        $(document).ready(function() {
            if (!$.cookie("JahiaForumView_${bindedComponent.identifier}")){
                $('#jahia-viewcount-${currentNode.UUID}').ajaxSubmit(function(){
                    $.cookie("JahiaForumView_${bindedComponent.identifier}", "viewed");
                }, "json");
           }
        });
    </script>
</template:addResources>

</c:if>
