<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>

<template:addResources type="css" resources="forum.css"/>
<c:set var="linked" value="${uiComponents:getBindedComponent(currentNode, renderContext, 'j:bindedComponent')}"/>
<c:if test="${not empty linked}">
    <c:set var="totalNumberOfPosts" value="0"/>
    <c:set var="totalNumberOfThreads" value="0"/>
  <template:addResources type="css" resources="forum.css"/>
  <template:addCacheDependency node="${linked}"/>
  <div class="topics">
    <jcr:nodeProperty node="${linked}" name="jcr:title" var="topicSubject"/>
    <div class="forum-box forum-box-style1 topics">
      <ul class="forum-list">
        <li class="forum-list-header">
          <dl class="icon">
            <dt>Sections</dt>
            <dd class="topics">
              <fmt:message key='topics'/>
            </dd>
            <dd class="posts">
              <fmt:message key='posts'/>
            </dd>
            <%--<dd class="posts">View</dd>--%>
            <dd class="lastpost"><span>
              <fmt:message key='last.post'/>
              </span></dd>
          </dl>
        </li>
      </ul>
      <ul class="forum-list forums">
        <c:forEach items="${linked.nodes}" var="section">
          <c:if test="${jcr:isNodeType(section, 'jnt:page')}">
              <template:addCacheDependency node="${section}"/>
            <li class="row">
                <c:choose>
                    <c:when test="${!jcr:isNodeType(linked, 'jmix:moderated') or jcr:hasPermission(linked, 'moderatePost')}">
                        <jcr:sql var="numberOfPostsQuery"
                                 sql="select * from [jnt:post] as post  where isdescendantnode(post, ['${section.path}'])
                                 order by post.[jcr:lastModified] desc"/>
                    </c:when>
                    <c:otherwise>
                        <jcr:sql var="numberOfPostsQuery"
                                 sql="select * from [jnt:post] as post  where isdescendantnode(post, ['${section.path}'])
                                 and post.['moderated']=true order by post.[jcr:lastModified] desc"/>
                    </c:otherwise>
                </c:choose>
                <c:set var="numberOfPosts" value="${numberOfPostsQuery.nodes.size}"/>
                <c:set var="totalNumberOfPosts" value="${numberOfPosts + totalNumberOfPosts}"/>
                <c:choose>
                    <c:when test="${!jcr:isNodeType(linked, 'jmix:moderated') or jcr:hasPermission(linked, 'moderatePost')}">
                        <jcr:sql var="numberOfTopicsQuery"
                                 sql="select * from [jnt:topic] as topic where isdescendantnode(topic, ['${section.path}']) order by topic.[jcr:lastModified] desc"/>
                    </c:when>
                    <c:otherwise>
                        <jcr:sql var="numberOfTopicsQuery"
                                 sql="select * from [jnt:topic] as topic where isdescendantnode(topic, ['${section.path}']) and topic.['moderated']=true order by topic.[jcr:lastModified] desc"/>
                    </c:otherwise>
                </c:choose>
                <c:set var="numberOfTopics" value="${numberOfTopicsQuery.nodes.size}"/>
                <c:set var="totalNumberOfThreads" value="${numberOfTopics + totalNumberOfThreads}"/>
              <c:forEach items="${numberOfPostsQuery.nodes}" var="node" varStatus="status" end="2">
                <c:if test="${status.first}">
                  <c:set value="${node}" var="lastModifiedNode"/>
                  <jcr:nodeProperty node="${node}" name="jcr:lastModified" var="lastModified"/>
                  <jcr:nodeProperty node="${lastModifiedNode}" name="jcr:createdBy" var="createdBy"/>
                </c:if>
              </c:forEach>
              <c:if test="${jcr:hasPermission(section, 'deleteSection')}">
                <template:tokenizedForm>
                  <form action="<c:url value='${url.base}${section.path}'/>" method="post"
                                          id="jahia-forum-section-delete-${section.UUID}">
                    <input type="hidden" name="jcrRedirectTo"
                                               value="<c:url value='${url.base}${renderContext.mainResource.node.path}'/>"/>
                    <%-- Define the output format for the newly created node by default html or by redirectTo--%>
                    <input type="hidden" name="jcrNewNodeOutputFormat" value="html"/>
                    <input type="hidden" name="jcrMethodToCall" value="delete"/>
                  </form>
                </template:tokenizedForm>
              </c:if>
              <dl class="icon iconsection">
                <dt title="posts">
                  <c:if test="${jcr:hasPermission(section, 'deleteSection')}">
                    <ul class="forum-profile-icons">
                      <li class="delete-post-icon"><a title="<fmt:message key='delete.section'/>" href="#"
                                                                        onclick="if (window.confirm('<fmt:message key='confirm.delete.section'/>')) {document.getElementById('jahia-forum-section-delete-${section.UUID}').submit();}"><span>
                        <fmt:message key='delete.section'/>
                        </span></a> </li>
                    </ul>
                  </c:if>
                  <a class="forum-title" href="<c:url value='${url.base}${section.path}.html'/>">
                  <jcr:nodeProperty node="${section}" name="jcr:title" var="sectionTitle" />
                  <c:out value="${sectionTitle.string}" />
                  </a> <br/>
                  <p> <c:out value="${section.properties['jcr:description'].string}" /> </p>
                </dt>
                <%--<dd class="topics">30</dd>--%>
                <dd class="topics">${numberOfTopics}</dd>
                <dd class="posts">${numberOfPosts}</dd>
                  <dd class="lastpost">
                      <c:if test="${numberOfPosts > 0}">
                          <span> <dfn>
                              <fmt:message key="last.post"/>
                          </dfn>
                              <fmt:message key="by"/>
                              <c:if test="${createdBy.string eq 'guest'}">
                                  ${createdBy.string} <br/><fmt:formatDate value="${lastModified.time}" dateStyle="full" type="both"/>
                              </c:if>
                              <c:if test="${createdBy.string ne 'guest'}">
                                  <a href="<c:url value='${url.base}${functions:lookupUser(createdBy.string).localPath}.forum-profile.html?jsite=${currentNode.resolveSite.identifier}'/>"><img height="9"
                                                                                                                                                                                                width="11"
                                                                                                                                                                                                title="View the latest post"
                                                                                                                                                                                                alt="View the latest post"
                                                                                                                                                                                                src="<c:url value='${url.currentModule}/css/img/icon_topic_latest.gif'/>"/>${createdBy.string} </a><br/>
                                  <fmt:formatDate value="${lastModified.time}" dateStyle="full" type="both"/>
                              </c:if>
                          </span>
                      </c:if>
                  </dd>
              </dl>
            </li>
              <c:set var="found" value="true"/>
          </c:if>
        </c:forEach>
        <c:if test="${not found}">
          <li class="row"><fmt:message key='no.topic.thread.found'/></li>
        </c:if>
      </ul>
      <div class="clear"></div>
    </div>
    <span><fmt:message key="total.threads"/>:&nbsp;${totalNumberOfThreads}</span>
    <span><fmt:message key="total.posts"/>:&nbsp;${totalNumberOfPosts}</span>
    </div>
</c:if>
