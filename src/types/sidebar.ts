/**
 * Page Sidebar type definitions
 * Used by PageSidebar components and pageSidebarConfig data
 */

export interface SidebarTocItem {
  label: string
  anchor: string
}

export interface SidebarProductItem {
  productId: string
  label: string
  color: string
  href: string
  external?: boolean
}

export interface SidebarLinkItem {
  label: string
  href: string
  external?: boolean
}

export interface SidebarCtaItem {
  label: string
  href: string
  variant: 'primary' | 'outline'
  external?: boolean
  action?: 'login'
}

export interface SidebarSection<T> {
  label: string
  items: T[]
  collapsed?: boolean
}

export interface PageSidebarConfig {
  toc: SidebarSection<SidebarTocItem>
  products?: SidebarSection<SidebarProductItem>
  links?: SidebarSection<SidebarLinkItem>
  cta?: SidebarCtaItem[]
}
