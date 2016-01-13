#ifndef REALM_SHARED_PTR_HPP
#define REALM_SHARED_PTR_HPP

#include <cstdlib> // size_t

namespace realm {
namespace util {

template<class T>
class SharedPtr
{
public:
    SharedPtr(T* p)
    {
        init(p);
    }

    SharedPtr()
    {
        init(0);
    }

    ~SharedPtr()
    {
        decref();
    }

    SharedPtr(const SharedPtr<T>& o) : m_ptr(o.m_ptr), m_count(o.m_count)
    {
        incref();
    }

    SharedPtr<T>& operator=(const SharedPtr<T>& o) {
        if (m_ptr == o.m_ptr)
            return *this;
        decref();
        m_ptr = o.m_ptr;
        m_count = o.m_count;
        incref();
        return *this;
    }

    T* operator->() const
    {
        return m_ptr;
    }

    T& operator*() const
    {
        return *m_ptr;
    }

    T* get() const
    {
        return m_ptr;
    }

    bool operator==(const SharedPtr<T>& o) const
    {
        return m_ptr == o.m_ptr;
    }

    bool operator!=(const SharedPtr<T>& o) const
    {
        return m_ptr != o.m_ptr;
    }

    bool operator<(const SharedPtr<T>& o) const
    {
        return m_ptr < o.m_ptr;
    }

    size_t ref_count() const
    {
        return *m_count;
    }

private:
    void init(T* p)
    {
        m_ptr = p;
        try {
            m_count = new size_t(1);
        }
        catch (...) {
            delete p;
            throw;
        }
    }

    void decref()
    {
        if (--(*m_count) == 0) {
            delete m_ptr;
            delete m_count;
        }
    }

    void incref()
    {
        ++(*m_count);
    }

    T* m_ptr;
    size_t* m_count;
};

}
}

#endif
