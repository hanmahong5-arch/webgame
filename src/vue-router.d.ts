import 'vue-router'

declare module 'vue-router' {
  interface RouteMeta {
    hideSidebar?: boolean
    pageSidebar?: boolean
  }
}
